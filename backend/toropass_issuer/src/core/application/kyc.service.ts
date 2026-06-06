import {
  BadRequestException,
  Inject,
  Injectable,
  InternalServerErrorException,
  NotFoundException,
} from '@nestjs/common';
import * as crypto from 'crypto';
import { PrismaService } from '../../infrastructure/database/prisma.service';
import { VerifyKycDto } from '../../presentation/dto/verify-kyc.dto';
import {
  BLOCKCHAIN_PORT,
  IBlockchainPort,
} from '../ports/blockchain.interface';
import { ILogger, LOGGER_PORT } from '../ports/logger.interface';

@Injectable()
export class KycService {
  constructor(
    private prisma: PrismaService,
    @Inject(BLOCKCHAIN_PORT) private blockchain: IBlockchainPort,
    @Inject(LOGGER_PORT) private logger: ILogger,
  ) { }

  async processKycVerification(
    userId: string,
    payload: VerifyKycDto,
  ): Promise<{ success: boolean; message: string }> {
    const walletRecord = await this.prisma.wallet.findFirst({
      where: { userId },
      include: { user: true },
    });

    if (!walletRecord) {
      throw new NotFoundException(
        `Wallet for user ${userId} not found in our system.`,
      );
    }

    if (walletRecord.user.kycVerified) {
      throw new BadRequestException('This user has already passed KYC.');
    }

    const isVerified = await this.blockchain.verifyAndAnchorKyc({
      firstName: payload.firstName,
      middleName: payload.middleName,
      lastName: payload.lastName,
      bvn: payload.bvn,
      currency: payload.currency,
      phoneNumber: payload.phoneNumber,
      dob: payload.dob,
      address: walletRecord.address,
    });

    if (!isVerified) {
      this.logger
        .logAlert({
          message: `KYC failed for user: ${userId}, wallet: ${walletRecord.address}`,
          slack: false,
        });
      throw new BadRequestException(
        'Identity verification failed. Please ensure your BVN and details match exactly.',
      );
    }

    const bvnHash = crypto
      .createHash('sha256')
      .update(payload.bvn)
      .digest('hex');
    const parsedDob = new Date(payload.dob);

    try {
      await this.prisma.user.update({
        where: { id: walletRecord.userId },
        data: {
          kycVerified: true,
          bvnHash: bvnHash,
          dateOfBirth: parsedDob,
        },
      });

      this.logger
        .logInfo({
          message: `User linked to wallet ${walletRecord.address} successfully passed KYC!`,
          slack: true,
        });

      return {
        success: true,
        message:
          'Identity verified and securely anchored to the Toronet blockchain.',
      };
    } catch (error) {
      this.logger
        .logAlert({
          message: `Database failure after successful KYC for ${userId}, wallet: ${walletRecord.address}`,
          error,
        });
      throw new InternalServerErrorException(
        'Verification succeeded, but we failed to save the status.',
      );
    }
  }
}
