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
  checkTnsAvailability(username: string): Promise<boolean>;
  provisionWallet(username: string, password: string): Promise<string>;
  resolveAddress(username: string): Promise<string | null>;
  validateCredentials(address: string, password: string): Promise<Boolean>;
  updateWalletPassword(address: string, oldPass: string, newPass: string): Promise<void>;
  checkHealth(): Promise<boolean>;
}