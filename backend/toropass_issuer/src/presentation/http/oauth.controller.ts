import { Body, Controller, Post, UseGuards } from '@nestjs/common';
import { OAuthService } from '../../core/application/oauth.service';
import { ApiKeyGuard } from '../../core/guards/api-key.guard';

@Controller({ path: 'oauth', version: '1' })
export class OAuthController {
  constructor(private oauthService: OAuthService) { }

  // Route 1: Triggered when user approves the consent prompt in Flutter
  @Post('authorize')
  @UseGuards(ApiKeyGuard)
  async authorize(
    @Body('client_id') clientId: string,
    @Body('user_id') userId: string,
    @Body('redirect_uri') redirectUri: string,
    @Body('scopes') scopes: string[],
  ) {
    const code = await this.oauthService.generateAuthorizationCode(clientId, userId, redirectUri, scopes);
    return { status: 'success', data: { code } };
  }

  // Route 2: Server-to-server endpoint for developer servers to get access tokens
  @Post('token')
  async issueToken(
    @Body('client_id') clientId: string,
    @Body('client_secret') clientSecret: string,
    @Body('code') code: string,
    @Body('redirect_uri') redirectUri: string,
  ) {
    return await this.oauthService.exchangeCodeForToken(clientId, clientSecret, code, redirectUri);
  }
}