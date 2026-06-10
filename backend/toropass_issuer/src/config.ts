import 'dotenv/config';
import { createWallet, getAddr, getSDKConfig, initializeSDK, isAdmin, isTNSAvailable, verifyWalletPassword } from 'torosdk';

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
    const username = "maverick"; // process.env[network === 'testnet' ? 'TESTNET_TNS_NAME' : 'MAINNET_TNS_NAME'] || '';

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
      const wallet = await createWallet({ username, password: 'Password123' });
      console.log(`[SDK] Provisioned new wallet with address:`, wallet);
    }
  } catch (error) {
    // Updated log message to reflect what the block is actually doing
    console.error(`[SDK] Error testing SDK connection:`, error);
  }
}

// Verify the password of an existing Toronet Wallet
async function verifyPassword() {
  try {
    const address = process.env[network === 'testnet' ? 'TESTNET_ADMIN_ADDRESS' : 'MAINNET_ADMIN_ADDRESS'] || '';
    const password = process.env[network === 'testnet' ? 'TESTNET_ADMIN_PASSWORD' : 'MAINNET_ADMIN_PASSWORD'] || '';

    if (!address || !password) {
      console.log('[SDK] No admin wallet address or password found in environment variables.');
      return;
    }

    console.log(`[SDK] Verifying password for wallet address`);
    const isValid = await verifyWalletPassword({ address, password });
    console.log(`[SDK] Wallet password verification: ${isValid}`);
  } catch (error) {
    console.error(`[SDK] Error verifying wallet password:`, error);
  }
}

// Verify the address is an admin
async function verifyAdminRole() {
  try {
    const address = process.env[network === 'testnet' ? 'TESTNET_ADMIN_ADDRESS' : 'MAINNET_ADMIN_ADDRESS'] || '';

    if (!address) {
      console.log('[SDK] No wallet address found in environment variables.');
      return;
    }

    console.log(`[SDK] Verifying admin role for wallet address`);
    const isAddrAdmin = await isAdmin({ address });
    console.log(`[SDK] Wallet admin status`, isAddrAdmin);

  } catch (error) {
    console.error(`[SDK] Error verifying wallet admin role:`, error);
  }
}

verifyAdminRole();
// verifyPassword();
// testSDKConnection();