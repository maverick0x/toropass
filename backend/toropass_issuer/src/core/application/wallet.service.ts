import {
  BadRequestException,
  Inject,
  Injectable,
  InternalServerErrorException,
} from '@nestjs/common';
import { createWallet, isTNSAvailable } from 'torosdk';
import { PrismaService } from '../../infrastructure/database/prisma.service';
import { ILogger, LOGGER_PORT } from '../ports/logger.interface';

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
        slack: false
      });
      throw new InternalServerErrorException('Failed to communicate with the Toronet network.');
    }
  }

  async provisionNewWallet(
    username: string,
    password: string,
  ): Promise<{ address: string; tnsName: string }> {
    const isAvailable = await this.checkTnsAvailability(username);

    if (!isAvailable) {
      throw new BadRequestException(
        `The username "${username}" is already taken on the network.`,
      );
    }

    try {
      const walletAddress = await createWallet({ username, password });

      await this.prisma.user.create({
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

      await this.logger.logInfo({
        message: `New wallet provisioned: ${username} (${walletAddress})`,
        slack: true,
      });

      return {
        address: walletAddress,
        tnsName: username,
      };
    } catch (error) {
      await this.logger.logAlert({
        message: `Failed to provision wallet for user: ${username}`,
        error,
      });
      throw new InternalServerErrorException(
        'An error occurred while generating the Web3 wallet.',
      );
    }
  }
}
