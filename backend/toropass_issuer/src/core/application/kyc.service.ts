import {
  BadRequestException,
  Inject,
  Injectable,
  InternalServerErrorException,
  NotFoundException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../../infrastructure/database/prisma.service';
import { VerifyKycDto } from '../../presentation/dto/verify-kyc.dto';
import {
  BLOCKCHAIN_PORT,
  IBlockchainPort,
} from '../ports/blockchain.interface';
import { ILogger, LOGGER_PORT } from '../ports/logger.interface';
import { hashBvn, legacyBvnHash } from '../security/credential-hash';

@Injectable()
export class KycService {
  private readonly bvnHashPepper: string;

  constructor(
    private prisma: PrismaService,
    configService: ConfigService,
    @Inject(BLOCKCHAIN_PORT) private blockchain: IBlockchainPort,
    @Inject(LOGGER_PORT) private logger: ILogger,
  ) {
    this.bvnHashPepper = configService.getOrThrow<string>('BVN_HASH_PEPPER');
    if (this.bvnHashPepper.length < 32) {
      throw new Error('BVN_HASH_PEPPER must contain at least 32 characters.');
    }
  }

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

    const bvnHash = hashBvn(payload.bvn, this.bvnHashPepper);
    const existingIdentity = await this.prisma.user.findFirst({
      where: {
        id: { not: userId },
        bvnHash: { in: [bvnHash, legacyBvnHash(payload.bvn)] },
      },
      select: { id: true },
    });

    if (existingIdentity) {
      throw new BadRequestException(
        'This identity is already linked to another ToroPass wallet.',
      );
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
      void this.logger.logAlert({
        message: `KYC failed for user: ${userId}, wallet: ${walletRecord.address}`,
        slack: false,
      });
      throw new BadRequestException(
        'Identity verification failed. Please ensure your BVN and details match exactly.',
      );
    }

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

      void this.logger.logInfo({
        message: `User linked to wallet ${walletRecord.address} successfully passed KYC!`,
        slack: true,
      });

      return {
        success: true,
        message:
          'Identity verified and securely anchored to the Toronet blockchain.',
      };
    } catch (error) {
      void this.logger.logAlert({
        message: `Database failure after successful KYC for ${userId}, wallet: ${walletRecord.address}`,
        error,
      });
      throw new InternalServerErrorException(
        'Verification succeeded, but we failed to save the status.',
      );
    }
  }
}
