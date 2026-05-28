import { IsNotEmpty, IsString, IsUrl } from 'class-validator';

export class CreateAppDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsUrl({}, { message: 'A valid redirect URI is required.' })
  @IsNotEmpty()
  redirectUri: string;
}
