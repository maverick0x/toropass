import { Inject, Injectable, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createWallet, getAddr, getSDKConfig, initializeSDK, isAddressKYCVerified, isTNSAvailable, performKYCForCustomer, updatePassword, verifyWalletPassword } from 'torosdk';
import {
  IBlockchainPort,
  IKycPayload,
} from '../../core/ports/blockchain.interface';
import { ILogger, LOGGER_PORT } from '../../core/ports/logger.interface';

@Injectable()
export class ToronetAdapter implements IBlockchainPort, OnModuleInit {
  private readonly network: 'mainnet' | 'testnet';
  private adminAddress: string;
  private adminPwd: string;

  constructor(
    private configService: ConfigService,
    @Inject(LOGGER_PORT) private logger: ILogger,
  ) {
    const configuredNetwork =
      this.configService.get<string>('BLOCKCHAIN_NETWORK')?.toLowerCase() ||
      'testnet';
    this.network = configuredNetwork === 'testnet' ? 'testnet' : 'mainnet';

    const adminAddressKey =
      this.network === 'testnet'
        ? 'TESTNET_ADMIN_ADDRESS'
        : 'MAINNET_ADMIN_ADDRESS';
    const adminPasswordKey =
      this.network === 'testnet'
        ? 'TESTNET_ADMIN_PASSWORD'
        : 'MAINNET_ADMIN_PASSWORD';

    this.adminAddress = this.configService.get<string>(adminAddressKey) || '';
    this.adminPwd = this.configService.get<string>(adminPasswordKey) || '';
  }

  async onModuleInit() {
    if (!this.adminAddress || !this.adminPwd) {
      this.logger.logAlert({
        message: `Toronet ${this.network} admin credentials are missing from .env.`,
        slack: true,
      });
    } else {
      this.logger.logInfo({
        message: `Toronet SDK Adapter initialized successfully for ${this.network}.`,
      });
    }

    initializeSDK({ network: this.network });
    const config = getSDKConfig();
    this.logger.logInfo({
      message: `SDK initialized with network: ${config.getNetwork().toUpperCase()} and base URL: ${config.getBaseURL()}`,
    });
  }

  getNetwork(): 'mainnet' | 'testnet' {
    return this.network;
  }

  async isWalletVerified(address: string): Promise<boolean> {
    try {
      const status = await isAddressKYCVerified({ address });

      return status.verified;
    } catch (error) {
      const message = `Failed to check KYC status for address: ${address}`;
      this.logger.logAlert({ message, error, slack: true });
      return false;
    }
  }

  async verifyAndAnchorKyc(payload: IKycPayload): Promise<boolean> {
    try {
      const isSuccessful = await performKYCForCustomer({
        ...payload,
        middleName: payload.middleName || '',
        admin: this.adminAddress,
        adminpwd: this.adminPwd,
      });

      return isSuccessful;
    } catch (error) {
      const message = `Toronet SDK KYC verification failed for wallet: ${payload.address}`;
      this.logger.logAlert({ message, error, slack: true, });
      return false;
    }
  }

  async checkTnsAvailability(username: string): Promise<boolean> {
    return await isTNSAvailable({ username });
  }

  async provisionWallet(username: string, password: string): Promise<string> {
    return await createWallet({ username, password });
  }

  async resolveAddress(username: string): Promise<string | null> {
    const rawAddress = await getAddr({ name: username });

    if (typeof rawAddress === 'string') return rawAddress;
    if (
      rawAddress &&
      typeof rawAddress === 'object' &&
      'address' in rawAddress
    ) {
      const candidate = (rawAddress as { address?: unknown }).address;
      if (typeof candidate === 'string') return candidate.toLowerCase();
    }
    return null;
  }

  async validateCredentials(
    address: string,
    password: string,
  ): Promise<Boolean> {
    return await verifyWalletPassword({ address, password });
  }

  async updateWalletPassword(
    address: string,
    oldPassword: string,
    newPassword: string,
  ): Promise<void> {
    await updatePassword({ address, oldPassword, newPassword });
  }

  async checkHealth(): Promise<boolean> {
    try {
      await this.checkTnsAvailability('admin');

      return true;
    } catch (error) {
      const message = 'Toronet Health Check Failed. Network might be unreachable.';
      this.logger.logAlert({ message, error, slack: true });

      return false;
    }
  }
}


