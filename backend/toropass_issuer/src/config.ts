// src/config.ts
import 'dotenv/config';
import { getAddr, getSDKConfig, initializeSDK, isTNSAvailable } from 'torosdk';

const configuredNetwork = process.env.BLOCKCHAIN_NETWORK?.toLowerCase() || 'testnet';
const network = configuredNetwork === 'testnet' ? 'testnet' : 'mainnet';

initializeSDK({ network });

const config = getSDKConfig();

console.log(`\n[SDK] Network : ${config.getNetwork()}`);
console.log(`[SDK] Base URL: ${config.getBaseURL()}\n`);

async function resolveAddress(username: string): Promise<string | null> {
  try {
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
  } catch (error) {
    console.error(`[SDK] Failed to fetch raw address:`, error);
    return null;
  }
}

async function testSDKConnection() {
  try {
    const username = process.env[network === 'testnet' ? 'TESTNET_TNS_NAME' : 'MAINNET_TNS_NAME'] || '';

    if (!username) {
      console.log('[SDK] No TNS username found in environment variables.');
      return;
    }

    const available = await isTNSAvailable({ username });
    console.log(`[SDK] TNS Availability for "${username}": ${available}`);

    if (!available) {
      const address = await resolveAddress(username);
      console.log(`[SDK] Admin Wallet Address: ${address}`);
    } else {
      console.log(`[SDK] TNS name "${username}" is available (no wallet exists yet).`);
    }
  } catch (error) {
    // Updated log message to reflect what the block is actually doing
    console.error(`[SDK] Error testing SDK connection:`, error);
  }
}

testSDKConnection();