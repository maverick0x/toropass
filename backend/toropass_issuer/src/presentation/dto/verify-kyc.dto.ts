export class VerifyKycDto {
  firstName!: string;
  middleName?: string;
  lastName!: string;
  bvn!: string;
  currency!: string;
  phoneNumber!: string;
  dob!: string; // Expected format: YYYY-MM-DD
}
