import {
  BadRequestException,
  Inject,
  Injectable,
  InternalServerErrorException,
  UnauthorizedException
} from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import * as crypto from 'crypto';
import { PrismaService } from '../../infrastructure/database/prisma.service';
import { BLOCKCHAIN_PORT, IBlockchainPort } from '../ports/blockchain.interface';
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
    @Inject(BLOCKCHAIN_PORT) private blockchain: IBlockchainPort,
    @Inject(LOGGER_PORT) private logger: ILogger,
  ) { }

  async checkTnsAvailability(username: string): Promise<boolean> {
    try {
      return await this.blockchain.checkTnsAvailability(username);
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
      const walletAddress = await this.blockchain.provisionWallet(username, password);
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
      const resolvedAddress = await this.blockchain.resolveAddress(username);
      if (!resolvedAddress) {
        throw new BadRequestException(`No wallet address was found for "${username}".`);
      }
      address = resolvedAddress;
    } catch (error) {
      if (error instanceof BadRequestException) throw error;
      await this.logger.logAlert({
        message: `Failed to resolve TNS address for username: ${username}`,
        error,
        slack: true,
      });
      throw new InternalServerErrorException('Failed to communicate with the Toronet network.');
    }

    const existingWallet = await this.prisma.wallet.findUnique({
      where: { tnsName: username },
      include: { user: true },
    });
    let userId = existingWallet?.userId;

    if (existingWallet) {
      const isMatch = await bcrypt.compare(password, existingWallet.user.password);
      if (!isMatch) {
        throw new UnauthorizedException('Invalid wallet password.');
      }

      if (existingWallet.address !== address) {
        await this.prisma.wallet.update({
          where: { id: existingWallet.id },
          data: { address },
        });
      }
    } else {
      let isValid: Boolean = false;
      try {
        isValid = await this.blockchain.validateCredentials(address, password);
      } catch (error) {
        throw new InternalServerErrorException('Toronet SDK verification failed.');
      }

      if (!isValid) throw new UnauthorizedException('Invalid wallet password.');

      const hashedPassword = await bcrypt.hash(password, 10);
      const user = await this.prisma.user.create({
        data: {
          password: hashedPassword,
          bvnHash: 'PENDING_' + username,
          dateOfBirth: new Date(),
          kycVerified: false,
          wallets: {
            create: { address, tnsName: username, network: 'testnet' },
          },
        },
      });
      userId = user.id;
    }

    const tokens = await this.issueTokens(userId ?? "");
    return { address, tnsName: username, tokens };
  }

  async changeWalletPassword(username: string, oldPassword: string, newPassword: string) {
    const existingWallet = await this.prisma.wallet.findUnique({
      where: { tnsName: username },
      include: { user: true },
    });

    if (!existingWallet || !existingWallet.user.password) {
      throw new BadRequestException('Wallet not fully registered in the system.');
    }

    const isMatch = await bcrypt.compare(oldPassword, existingWallet.user.password);
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
      await this.logger.logAlert({
        message: `Toronet SDK failed to update password for: ${username}`,
        error,
        slack: true,
      });
      throw new InternalServerErrorException('Failed to update password on the Toronet network.');
    }

    const hashedNewPassword = await bcrypt.hash(newPassword, 10);
    await this.prisma.user.update({
      where: { id: existingWallet.user.id },
      data: { password: hashedNewPassword },
    });

    return { success: true, message: 'Password changed successfully.' };
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
}
