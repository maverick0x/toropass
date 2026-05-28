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
    payload: VerifyKycDto,
  ): Promise<{ success: boolean; message: string }> {
    // 1. Verify the wallet actually exists in our system before paying gas fees
    const walletRecord = await this.prisma.wallet.findUnique({
      where: { address: payload.address },
      include: { user: true },
    });

    if (!walletRecord) {
      throw new NotFoundException(
        `Wallet address ${payload.address} not found in our system.`,
      );
    }

    if (walletRecord.user.kycVerified) {
      throw new BadRequestException('This user has already passed KYC.');
    }

    // 2. Ask Toronet SDK to verify identity AND anchor it to the blockchain
    const isVerified = await this.blockchain.verifyAndAnchorKyc(payload);

    if (!isVerified) {
      await this.logger.logAlert({
        message: `KYC failed for wallet: ${payload.address}`,
        slack: false,
      });
      throw new BadRequestException(
        'Identity verification failed. Please ensure your BVN and details match exactly.',
      );
    }

    // 3. Hash the BVN for secure, anonymized storage
    const bvnHash = crypto
      .createHash('sha256')
      .update(payload.bvn)
      .digest('hex');
    const parsedDob = new Date(payload.dob);

    try {
      // 4. Commit the verified status to the database
      await this.prisma.user.update({
        where: { id: walletRecord.userId },
        data: {
          kycVerified: true,
          bvnHash: bvnHash,
          dateOfBirth: parsedDob,
          // Since Toronet anchors it automatically via the SDK, we just mark it verified locally.
        },
      });

      // 5. Fire the success notification
      await this.logger.logInfo({
        message: `User linked to wallet ${payload.address} successfully passed KYC!`,
        slack: true,
      });

      return {
        success: true,
        message:
          'Identity verified and securely anchored to the Toronet blockchain.',
      };
    } catch (error) {
      await this.logger.logAlert({
        message: `Database failure after successful KYC for ${payload.address}`,
        error,
      });
      throw new InternalServerErrorException(
        'Verification succeeded, but we failed to save the status.',
      );
    }
  }
}
