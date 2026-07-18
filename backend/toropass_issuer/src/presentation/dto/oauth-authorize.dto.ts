import {
  ArrayNotEmpty,
  Equals,
  IsArray,
  IsIn,
  IsNotEmpty,
  IsString,
  Matches,
} from 'class-validator';
import { OAUTH_SCOPES } from '../../core/application/types/oauth-scope.type';

const redirectUriPattern = /^[a-z][a-z0-9+.-]*:\/\/\S+$/i;
const pkceChallengePattern = /^[A-Za-z0-9_-]{43}$/;

export class OAuthAuthorizeDto {
  @IsString()
  @IsNotEmpty()
  client_id!: string;

  @IsString()
  @Matches(redirectUriPattern, {
    message: 'redirect_uri must be an absolute URI.',
  })
  redirect_uri!: string;

  @IsArray()
  @ArrayNotEmpty()
  @IsString({ each: true })
  @IsIn(OAUTH_SCOPES, { each: true })
  scopes!: string[];

  @IsString()
  @Matches(pkceChallengePattern, {
    message: 'code_challenge must be a valid S256 PKCE challenge.',
  })
  code_challenge!: string;

  @Equals('S256')
  code_challenge_method!: 'S256';
}
