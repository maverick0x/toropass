import { IsNotEmpty, IsOptional, IsString, Matches } from 'class-validator';

export class VerifyKycDto {
  @IsString()
  @IsNotEmpty()
  firstName!: string;

  @IsOptional()
  @IsString()
  middleName?: string;

  @IsString()
  @IsNotEmpty()
  lastName!: string;

  @IsString()
  @Matches(/^\d{11}$/, {
    message: 'bvn must contain exactly 11 digits',
  })
  bvn!: string;

  @IsString()
  @IsNotEmpty()
  currency!: string;

  @IsString()
  @IsNotEmpty()
  phoneNumber!: string;

  @IsString()
  @Matches(/^\d{4}-\d{2}-\d{2}$/, {
    message: 'dob must be in YYYY-MM-DD format',
  })
  dob!: string; // Expected format: YYYY-MM-DD
}
