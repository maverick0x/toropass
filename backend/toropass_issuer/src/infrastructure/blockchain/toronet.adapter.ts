import { Inject, Injectable, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as ToronetSDK from 'torosdk';
import { updatePassword, verifyWalletPassword } from 'torosdk';
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

  async checkTnsAvailability(username: string): Promise<boolean> {
    return await ToronetSDK.isTNSAvailable({ username });
  }

  async provisionWallet(username: string, password: string): Promise<string> {
    return await ToronetSDK.createWallet({ username, password });
  }

  async resolveAddress(username: string): Promise<string | null> {
    const rawAddress = await ToronetSDK.getAddr({ name: username });

    // You can move your extractStringField helper logic here to keep it contained
    if (typeof rawAddress === 'string') return rawAddress;
    if (rawAddress && typeof rawAddress === 'object' && 'address' in rawAddress) {
      const candidate = (rawAddress as { address?: unknown }).address;
      if (typeof candidate === 'string') return candidate.toLowerCase();
    }
    return null;
  }

  async validateCredentials(address: string, password: string): Promise<Boolean> {
    return await verifyWalletPassword({ address, password });
  }

  async updateWalletPassword(address: string, oldPass: string, newPass: string): Promise<void> {
    await updatePassword({
      address,
      oldPassword: oldPass,
      newPassword: newPass,
    });
  }

  async checkHealth(): Promise<boolean> {
    return true;
  }
}
