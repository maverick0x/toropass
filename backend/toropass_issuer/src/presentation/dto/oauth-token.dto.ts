import { IsNotEmpty, IsOptional, IsString, Matches } from 'class-validator';

const redirectUriPattern = /^[a-z][a-z0-9+.-]*:\/\/\S+$/i;
const pkceVerifierPattern = /^[A-Za-z0-9\-._~]{43,128}$/;

export class OAuthTokenDto {
  @IsString()
  @IsNotEmpty()
  client_id!: string;

  @IsString()
  @IsNotEmpty()
  code!: string;

  @IsString()
  @Matches(redirectUriPattern, {
    message: 'redirect_uri must be an absolute URI.',
  })
  redirect_uri!: string;

  @IsString()
  @Matches(pkceVerifierPattern, {
    message: 'code_verifier must be a valid PKCE verifier.',
  })
  code_verifier!: string;

  @IsOptional()
  @IsString()
  @IsNotEmpty()
  client_secret?: string;
}
