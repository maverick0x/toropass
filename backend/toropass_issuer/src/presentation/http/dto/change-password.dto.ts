import { IsNotEmpty, IsString, MinLength } from 'class-validator';

export class ChangePasswordDto {
  @IsString()
  @IsNotEmpty()
  username!: string;

  @IsString()
  @IsNotEmpty()
  oldPassword!: string;

  @IsString()
  @IsNotEmpty()
  @MinLength(6)
  newPassword!: string;
}