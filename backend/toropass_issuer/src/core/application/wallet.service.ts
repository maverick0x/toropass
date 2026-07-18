import {
  BadRequestException,
  Inject,
  Injectable,
  InternalServerErrorException,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import * as crypto from 'crypto';
import { PrismaService } from '../../infrastructure/database/prisma.service';
import {
  BLOCKCHAIN_PORT,
  IBlockchainPort,
} from '../ports/blockchain.interface';
import { ILogger, LOGGER_PORT } from '../ports/logger.interface';
import {
  digestOpaqueToken,
  tokenHashesMatch,
} from '../security/credential-hash';
import { RefreshTokenPayload } from './types/refresh-token-payload.type';
import { WalletAuthTokens } from './types/wallet-auth-tokens.type';
import { WalletProfile } from './types/wallet-profile.type';

const REFRESH_TOKEN_LIFETIME_MS = 30 * 24 * 60 * 60 * 1000;

@Injectable()
export class WalletService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
    @Inject(BLOCKCHAIN_PORT) private blockchain: IBlockchainPort,
    @Inject(LOGGER_PORT) private logger: ILogger,
  ) {}

  async checkTnsAvailability(username: string): Promise<boolean> {
    try {
      return await this.blockchain.checkTnsAvailability(username);
    } catch (error) {
      void this.logger.logAlert({
        message: `Toronet SDK failed during TNS check for username: ${username}`,
        error,
        slack: true,
      });
      throw new InternalServerErrorException(
        'Failed to communicate with the Toronet network.',
      );
    }
  }

  async provisionNewWallet(
    username: string,
    password: string,
  ): Promise<{ address: string; tnsName: string; tokens: WalletAuthTokens }> {
    const isAvailable = await this.checkTnsAvailability(username);
    const network = this.blockchain.getNetwork();

    if (!isAvailable) {
      throw new BadRequestException(
        `The username "${username}" is already taken on the network.`,
      );
    }

    try {
      const walletAddress = await this.blockchain.provisionWallet(
        username,
        password,
      );
      const hashedPassword = await bcrypt.hash(password, 10);
      const user = await this.prisma.user.create({
        data: {
          password: hashedPassword,
          bvnHash: 'PENDING_' + username,
          dateOfBirth: new Date(),
          kycVerified: false,
          wallets: {
            create: {
              address: walletAddress,
              tnsName: username,
              network,
            },
          },
        },
      });

      const tokens = await this.issueTokens(user.id);

      void this.logger.logInfo({
        message: `New wallet provisioned:\n${username}\n(${walletAddress})`,
        slack: true,
      });

      return {
        address: walletAddress,
        tnsName: username,
        tokens,
      };
    } catch (error) {
      void this.logger.logAlert({
        message: `Failed to provision wallet for user: ${username}`,
        error,
        slack: true,
      });
      throw new InternalServerErrorException(
        'An error occurred while generating the Web3 wallet.',
      );
    }
  }

  async validateExistingWallet(
    username: string,
    password: string,
  ): Promise<{ address: string; tnsName: string; tokens: WalletAuthTokens }> {
    let address: string;
    const network = this.blockchain.getNetwork();

    try {
      const resolvedAddress = await this.blockchain.resolveAddress(username);
      if (!resolvedAddress) {
        throw new BadRequestException(
          `No wallet address was found for "${username}".`,
        );
      }
      address = resolvedAddress;
    } catch (error) {
      if (error instanceof BadRequestException) throw error;
      void this.logger.logAlert({
        message: `Failed to resolve TNS address for username: ${username}`,
        error,
        slack: true,
      });
      throw new InternalServerErrorException(
        'Failed to communicate with the Toronet network.',
      );
    }

    const existingWallet = await this.prisma.wallet.findUnique({
      where: { tnsName: username },
      include: { user: true },
    });
    let userId = existingWallet?.userId;

    if (existingWallet) {
      const isMatch = await bcrypt.compare(
        password,
        existingWallet.user.password,
      );
      if (!isMatch) {
        throw new UnauthorizedException('Invalid wallet password.');
      }

      if (existingWallet.address !== address) {
        await this.prisma.wallet.update({
          where: { id: existingWallet.id },
          data: { address },
        });
      }

      const isVerified = await this.blockchain.isWalletVerified(address);
      if (isVerified && !existingWallet.user.kycVerified) {
        await this.prisma.user.update({
          where: { id: existingWallet.userId },
          data: { kycVerified: true },
        });
      }
    } else {
      let isValid = false;
      try {
        isValid = Boolean(
          await this.blockchain.validateCredentials(address, password),
        );
      } catch {
        throw new InternalServerErrorException(
          'Toronet SDK wallet validation failed.',
        );
      }

      if (!isValid) throw new UnauthorizedException('Invalid wallet password.');

      let isVerified = false;
      try {
        isVerified = await this.blockchain.isWalletVerified(address);
      } catch (error) {
        void this.logger.logAlert({
          message: `Failed to verify wallet for username: ${username}`,
          error,
          slack: true,
        });
      }

      const hashedPassword = await bcrypt.hash(password, 10);
      const user = await this.prisma.user.create({
        data: {
          password: hashedPassword,
          bvnHash: isVerified ? 'VERIFIED_' + username : 'PENDING_' + username,
          dateOfBirth: new Date(),
          kycVerified: isVerified,
          wallets: {
            create: { address, tnsName: username, network },
          },
        },
      });
      userId = user.id;
    }

    const tokens = await this.issueTokens(userId ?? '');
    return { address, tnsName: username, tokens };
  }

  async getWalletProfile(userId: string): Promise<WalletProfile> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: { wallets: { where: { isActive: true }, take: 1 } },
    });

    if (!user) {
      throw new UnauthorizedException('User account no longer exists.');
    }

    const activeWallet = user.wallets[0] ?? null;

    return {
      id: user.id,
      kycVerified: user.kycVerified,
      kycAnchorHash: user.kycAnchorHash,
      wallet: activeWallet
        ? {
            address: activeWallet.address,
            tnsName: activeWallet.tnsName,
            network: activeWallet.network,
          }
        : null,
    };
  }

  async changeWalletPassword(
    userId: string,
    oldPassword: string,
    newPassword: string,
  ) {
    const existingWallet = await this.prisma.wallet.findFirst({
      where: { userId, isActive: true },
      include: { user: true },
    });

    if (!existingWallet || !existingWallet.user.password) {
      throw new BadRequestException(
        'Wallet not fully registered in the system.',
      );
    }

    const isMatch = await bcrypt.compare(
      oldPassword,
      existingWallet.user.password,
    );
    if (!isMatch) {
      throw new UnauthorizedException('Invalid current password.');
    }

    try {
      await this.blockchain.updateWalletPassword(
        existingWallet.address,
        oldPassword,
        newPassword,
      );
    } catch (error) {
      void this.logger.logAlert({
        message: `Toronet SDK failed to update password for: ${existingWallet.tnsName}`,
        error,
        slack: true,
      });
      throw new InternalServerErrorException(
        'Failed to update password on the Toronet network.',
      );
    }

    const hashedNewPassword = await bcrypt.hash(newPassword, 10);
    await this.prisma.user.update({
      where: { id: existingWallet.user.id },
      data: { password: hashedNewPassword },
    });

    return { success: true, message: 'Password changed successfully.' };
  }

  async refreshSession(refreshToken: string): Promise<WalletAuthTokens> {
    let payload: RefreshTokenPayload;

    try {
      payload =
        await this.jwtService.verifyAsync<RefreshTokenPayload>(refreshToken);
    } catch {
      throw new UnauthorizedException(
        'Invalid or expired refresh token. Please log in again.',
      );
    }

    if (
      payload.tokenUse !== 'refresh' ||
      !payload.sub ||
      !payload.sessionId ||
      !payload.familyId
    ) {
      throw new UnauthorizedException(
        'Invalid or expired refresh token. Please log in again.',
      );
    }

    const tokenHash = digestOpaqueToken(refreshToken);
    const replacement = await this.buildTokenPair(
      payload.sub,
      payload.familyId,
    );

    const result = await this.prisma.$transaction(async (transaction) => {
      const session = await transaction.userSession.findUnique({
        where: { tokenHash },
      });
      const now = new Date();

      if (
        !session ||
        session.id !== payload.sessionId ||
        session.userId !== payload.sub ||
        session.familyId !== payload.familyId ||
        !tokenHashesMatch(session.tokenHash, tokenHash)
      ) {
        return 'invalid' as const;
      }

      if (session.revokedAt || session.reuseDetectedAt) {
        await transaction.userSession.updateMany({
          where: { familyId: session.familyId },
          data: { revokedAt: now, reuseDetectedAt: now },
        });
        return 'reused' as const;
      }

      if (session.expiresAt <= now) {
        await transaction.userSession.update({
          where: { id: session.id },
          data: { revokedAt: now },
        });
        return 'invalid' as const;
      }

      const claimed = await transaction.userSession.updateMany({
        where: {
          id: session.id,
          revokedAt: null,
          reuseDetectedAt: null,
        },
        data: {
          revokedAt: now,
          replacedById: replacement.session.id,
        },
      });

      if (claimed.count !== 1) {
        await transaction.userSession.updateMany({
          where: { familyId: session.familyId },
          data: { revokedAt: now, reuseDetectedAt: now },
        });
        return 'reused' as const;
      }

      await transaction.userSession.create({
        data: replacement.session,
      });
      return 'rotated' as const;
    });

    if (result === 'reused') {
      throw new UnauthorizedException(
        'Refresh token reuse detected. Please log in again.',
      );
    }

    if (result === 'invalid') {
      throw new UnauthorizedException(
        'Invalid or expired refresh token. Please log in again.',
      );
    }

    return replacement.tokens;
  }

  private async issueTokens(userId: string): Promise<WalletAuthTokens> {
    const tokenPair = await this.buildTokenPair(userId, crypto.randomUUID());

    await this.prisma.userSession.create({ data: tokenPair.session });
    return tokenPair.tokens;
  }

  private async buildTokenPair(userId: string, familyId: string) {
    const sessionId = crypto.randomUUID();
    const accessToken = await this.jwtService.signAsync(
      { sub: userId, tokenUse: 'access' },
      { expiresIn: '15m' },
    );
    const refreshToken = await this.jwtService.signAsync(
      {
        sub: userId,
        sessionId,
        familyId,
        tokenUse: 'refresh',
      } satisfies RefreshTokenPayload,
      { expiresIn: '30d' },
    );

    return {
      tokens: {
        accessToken,
        refreshToken,
      },
      session: {
        id: sessionId,
        userId,
        tokenHash: digestOpaqueToken(refreshToken),
        familyId,
        expiresAt: new Date(Date.now() + REFRESH_TOKEN_LIFETIME_MS),
      },
    };
  }
}
