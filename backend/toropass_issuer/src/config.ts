// src/config.ts
import 'dotenv/config';
import { getSDKConfig, initializeSDK } from 'torosdk';

initializeSDK({ network: 'mainnet' });

const config = getSDKConfig();

console.log(`\n[SDK] Network : ${config.getNetwork()}`);
console.log(`[SDK] Base URL: ${config.getBaseURL()}\n`);

export const ADMIN_ADDRESS = process.env.ADMIN_ADDRESS || '';
export const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || '';
