// src/config.ts
import 'dotenv/config';
import { createWallet, getSDKConfig, initializeSDK } from 'torosdk';

const configuredNetwork = process.env.BLOCKCHAIN_NETWORK?.toLowerCase() || 'testnet';
const network = configuredNetwork === 'testnet' ? 'testnet' : 'mainnet';

initializeSDK({ network });

const config = getSDKConfig();

console.log(`\n[SDK] Network : ${config.getNetwork()}`);
console.log(`[SDK] Base URL: ${config.getBaseURL()}\n`);

async function testSDKConnection() {
  try {
    const testWallet = await createWallet({ username: 'testuser', password: 'testpassword' });
    console.log(`[SDK] Test wallet created successfully. Address: ${testWallet}\n`);
  } catch (error) {
    console.error(`[SDK] Error creating test wallet: ${error}`);
  }
}

testSDKConnection();

export const BLOCKCHAIN_NETWORK = network;
export const ADMIN_ADDRESS =
  network === 'testnet'
    ? process.env.TESTNET_ADMIN_ADDRESS || ''
    : process.env.MAINNET_ADMIN_ADDRESS || '';
export const ADMIN_PASSWORD =
  network === 'testnet'
    ? process.env.TESTNET_ADMIN_PASSWORD || ''
    : process.env.MAINNET_ADMIN_PASSWORD || '';
