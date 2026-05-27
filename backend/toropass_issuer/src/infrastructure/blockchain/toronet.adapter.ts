import { Inject, Injectable, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as ToronetSDK from 'torosdk';
import {
  IBlockchainPort,
  IKycPayload,
} from '../../core/ports/blockchain.interface';
import { ILogger, LOGGER_PORT } from '../../core/ports/logger.interface';

@Injectable()
export class ToronetAdapter implements IBlockchainPort, OnModuleInit {
  private adminAddress: string;
  private adminPwd: string;

  constructor(
    private configService: ConfigService,
    @Inject(LOGGER_PORT) private logger: ILogger,
  ) {
    this.adminAddress =
      this.configService.get<string>('MAINNET_ADMIN_ADDRESS') || '';
    this.adminPwd =
      this.configService.get<string>('MAINNET_ADMIN_PASSWORD') || '';
  }

  async onModuleInit() {
    if (!this.adminAddress || !this.adminPwd) {
      await this.logger.logAlert({
        message: 'Toronet Admin credentials are missing from .env!',
      });
    } else {
      await this.logger.logInfo({
        message: 'Toronet SDK Adapter initialized successfully.',
        slack: false,
      });
    }
  }

  async verifyAndAnchorKyc(payload: IKycPayload): Promise<boolean> {
    try {
      this.logger.logInfo({
        message: `Initiating Toronet SDK KYC verification for wallet: ${payload.address}`,
        slack: false,
      });

      // Execute the built-in KYC method from the SDK
      const isSuccessful = await ToronetSDK.performKYCForCustomer({
        ...payload,
        middleName: payload.middleName || '',
        admin: this.adminAddress,
        adminpwd: this.adminPwd,
      });

      return isSuccessful;
    } catch (error) {
      this.logger.logAlert({
        message: `Toronet SDK KYC failed for wallet: ${payload.address}`,
        error,
      });
      return false;
    }
  }

  async checkHealth(): Promise<boolean> {
    return true;
  }
}
