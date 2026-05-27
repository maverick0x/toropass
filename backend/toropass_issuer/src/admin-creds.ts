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

generateAdminWallet();
