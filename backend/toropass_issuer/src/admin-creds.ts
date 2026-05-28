import * as ToronetSDK from 'torosdk';

async function generateAdminWallet() {
  ToronetSDK.initializeSDK({ network: 'testnet' });

  // 1. Choose a highly secure username and password
  const adminUsername = 'admin';
  const adminPassword = 'xxxxxxxxxx'; // This becomes ADMIN_PASSWORD

  // 2. Create the wallet on the network
  const walletAddress = await ToronetSDK.createWallet({
    username: adminUsername,
    password: adminPassword,
  });

  console.log(`Your Admin Address is: ${walletAddress}`);
  // This output becomes your TORONET_ADMIN_ADDRESS
}

function extractStringField<K extends string>(
  rawData: unknown,
  key: K
): string | null {
  if (typeof rawData === 'string') {
    return rawData;
  }

  if (rawData && typeof rawData === 'object' && key in rawData) {
    const candidate = (rawData as Record<K, unknown>)[key];

    if (typeof candidate === 'string') {
      return candidate.toLowerCase();
    }
  }

  return null;
}

async function changePassword() {
  const username = "user";
  const password = "password";
  const newPassword = "new-password";

  let address: string = '';

  ToronetSDK.initializeSDK({ network: 'mainnet' });

  try {
    const rawAddress: unknown = await ToronetSDK.getAddr({ name: username });
    const resolvedAddress = extractStringField(rawAddress, 'address');

    if (!resolvedAddress) console.error(`No wallet address was found for "${username}".`);
    address = resolvedAddress;
  } catch (error) {
    console.error(`Failed to resolve TNS address for username: ${username}`, error);
  }

  try {
    await ToronetSDK.updatePassword({
      address,
      oldPassword: password,
      newPassword: newPassword,
    });
    console.log('Password changed successfully!');
  } catch (error) {
    console.error('Error changing password:', error);
  }
}

// Uncomment the function you want to run
// generateAdminWallet();
changePassword();