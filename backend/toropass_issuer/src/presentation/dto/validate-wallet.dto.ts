import { IsNotEmpty, IsString } from 'class-validator';

export class ValidateWalletDto {
  @IsString()
  @IsNotEmpty()
  username!: string;

  @IsString()
  @IsNotEmpty()
  password!: string;
}
