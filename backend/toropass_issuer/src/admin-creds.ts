import * as ToronetSDK from 'torosdk';

async function generateAdminWallet() {
  const configuredNetwork = process.env.BLOCKCHAIN_NETWORK?.toLowerCase() || 'testnet';
  const network = configuredNetwork === 'mainnet' ? 'mainnet' : 'testnet';

  ToronetSDK.initializeSDK({ network });

  // 1. Choose a highly secure username and password
  const adminUsername = 'admin';
  const adminPassword = 'xxxxxxxxxx';

  // 2. Create the wallet on the network
  const walletAddress = await ToronetSDK.createWallet({
    username: adminUsername,
    password: adminPassword,
  });

  console.log(`Your Admin Address is: ${walletAddress}`);
  console.log(
    `Store it as ${network === 'mainnet' ? 'MAINNET_ADMIN_ADDRESS' : 'TESTNET_ADMIN_ADDRESS'}.`,
  );
  console.log(
    `Store the password as ${network === 'mainnet' ? 'MAINNET_ADMIN_PASSWORD' : 'TESTNET_ADMIN_PASSWORD'}.`,
  );
}

// generateAdminWallet();
