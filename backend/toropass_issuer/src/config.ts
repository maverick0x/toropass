// src/config.ts
import 'dotenv/config';
import { getSDKConfig, initializeSDK } from 'torosdk';

const configuredNetwork = process.env.TORONET_NETWORK?.toLowerCase() || 'mainnet';
const network = configuredNetwork === 'testnet' ? 'testnet' : 'mainnet';

initializeSDK({ network });

const config = getSDKConfig();

console.log(`\n[SDK] Network : ${config.getNetwork()}`);
console.log(`[SDK] Base URL: ${config.getBaseURL()}\n`);

export const TORONET_NETWORK = network;
export const ADMIN_ADDRESS =
  network === 'testnet'
    ? process.env.TESTNET_ADMIN_ADDRESS || ''
    : process.env.MAINNET_ADMIN_ADDRESS || '';
export const ADMIN_PASSWORD =
  network === 'testnet'
    ? process.env.TESTNET_ADMIN_PASSWORD || ''
    : process.env.MAINNET_ADMIN_PASSWORD || '';
