export type WalletProfile = {
  id: string;
  kycVerified: boolean;
  kycAnchorHash: string | null;
  wallet: {
    address: string;
    tnsName: string | null;
    network: string;
  } | null;
};
