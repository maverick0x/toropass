import {
  BadRequestException,
  Inject,
  Injectable,
  InternalServerErrorException,
  UnauthorizedException,
} from '@nestjs/common';
import * as crypto from 'crypto';
import {
  createWallet,
  getAddr,
  isTNSAvailable,
  verifyWalletPassword,
} from 'torosdk';
import { PrismaService } from '../../infrastructure/database/prisma.service';
import { ILogger, LOGGER_PORT } from '../ports/logger.interface';

type WalletAuthTokens = {
  accessToken: string;
  refreshToken: string;
  accessTokenExpiresAt: Date;
  refreshTokenExpiresAt: Date;
};

@Injectable()
export class WalletService {
  constructor(
    private prisma: PrismaService,
    @Inject(LOGGER_PORT) private logger: ILogger,
  ) { }

  async checkTnsAvailability(username: string): Promise<boolean> {
    try {
      const isAvailable = await isTNSAvailable({ username });
      return isAvailable;
    } catch (error) {
      await this.logger.logAlert({
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

    if (!isAvailable) {
      throw new BadRequestException(
        `The username "${username}" is already taken on the network.`,
      );
    }

    try {
      const walletAddress = await createWallet({ username, password });

      const user = await this.prisma.user.create({
        data: {
          bvnHash: 'PENDING_' + username, // Will be updated during KYC
          dateOfBirth: new Date(), // Will be updated during KYC
          kycVerified: false,
          wallets: {
            create: {
              address: walletAddress,
              tnsName: username,
              network: 'testnet',
            },
          },
        },
      });

      const tokens = await this.issueTokens(user.id);

      await this.logger.logInfo({
        message: `New wallet provisioned:\n${username}\n(${walletAddress})`,
        slack: true,
      });

      return {
        address: walletAddress,
        tnsName: username,
        tokens,
      };
    } catch (error) {
      await this.logger.logAlert({
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

    try {
      const rawAddress: unknown = await getAddr({ name: username });
      this.logger.logInfo({
        message: `Raw address retrieved for username "${username}": ${JSON.stringify(
          rawAddress,
        )}`,
      });
      const resolvedAddress = this.extractAddress(rawAddress);
      this.logger.logInfo({
        message: `Resolved address for username "${username}": ${resolvedAddress}`,
      });
      if (!resolvedAddress) {
        throw new BadRequestException(
          `No wallet address was found for "${username}".`,
        );
      }
      address = resolvedAddress;
    } catch (error) {
      if (error instanceof BadRequestException) {
        throw error;
      }
      await this.logger.logAlert({
        message: `Failed to resolve TNS address for username: ${username}`,
        error,
        slack: true,
      });
      throw new InternalServerErrorException(
        'Failed to communicate with the Toronet network.',
      );
    }

    let isValid: Boolean = false;
    try {
      isValid = await verifyWalletPassword({ address, password });
    } catch (error) {
      await this.logger.logAlert({
        message: `Toronet SDK password verification failed for username: ${username}`,
        error,
        // slack: true,
      });
      throw new InternalServerErrorException(
        'Failed to communicate with the Toronet network.',
      );
    }

    if (!isValid) {
      throw new UnauthorizedException('Invalid wallet password.');
    }

    const existingWallet = await this.prisma.wallet.findUnique({
      where: { tnsName: username },
      include: { user: true },
    });

    let userId = existingWallet?.userId;
    if (!userId) {
      const user = await this.prisma.user.create({
        data: {
          bvnHash: 'PENDING_' + username,
          dateOfBirth: new Date(),
          kycVerified: false,
          wallets: {
            create: {
              address,
              tnsName: username,
              network: 'testnet',
            },
          },
        },
      });
      userId = user.id;
    } else if (existingWallet && existingWallet.address !== address) {
      await this.prisma.wallet.update({
        where: { id: existingWallet.id },
        data: { address },
      });
    }

    const tokens = await this.issueTokens(userId);

    return {
      address,
      tnsName: username,
      tokens,
    };
  }

  private async issueTokens(userId: string): Promise<WalletAuthTokens> {
    const accessToken = 'toro_at_' + crypto.randomBytes(32).toString('hex');
    const refreshToken = 'toro_rt_' + crypto.randomBytes(48).toString('hex');
    const accessTokenExpiresAt = new Date(Date.now() + 15 * 60 * 1000);
    const refreshTokenExpiresAt = new Date(
      Date.now() + 30 * 24 * 60 * 60 * 1000,
    );

    await this.prisma.userSession.create({
      data: {
        userId,
        accessToken,
        refreshToken,
        accessExpiresAt: accessTokenExpiresAt,
        refreshExpiresAt: refreshTokenExpiresAt,
      },
    });

    return {
      accessToken,
      refreshToken,
      accessTokenExpiresAt,
      refreshTokenExpiresAt,
    };
  }

  private extractAddress(rawAddress: unknown): string | null {
    if (typeof rawAddress === 'string') {
      return rawAddress;
    }

    if (
      rawAddress &&
      typeof rawAddress === 'object' &&
      'address' in rawAddress
    ) {
      const candidate = (rawAddress as { address?: unknown }).address;
      if (typeof candidate === 'string') {
        return candidate.toLowerCase();
      }
    }

    return null;
  }
}
