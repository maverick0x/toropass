export const BLOCKCHAIN_PORT = 'BLOCKCHAIN_PORT';

export interface IKycPayload {
  firstName: string;
  middleName?: string;
  lastName: string;
  bvn: string;
  currency: string;
  phoneNumber: string;
  dob: string; // Format: YYYY-MM-DD
  address: string; // The user's Toronet wallet
}

export interface IBlockchainPort {
  verifyAndAnchorKyc(payload: IKycPayload): Promise<boolean>;
  checkHealth(): Promise<boolean>;
}