import { Body, Controller, Post, UseGuards } from '@nestjs/common';
import { OAuthService } from '../../core/application/oauth.service';
import { ApiKeyGuard } from '../../core/guards/api-key.guard';
import { CreateAppDto } from './dto/create-app.dto';

@Controller({ path: 'oauth', version: '1' })
export class OAuthController {
  constructor(private oauthService: OAuthService) { }

  @Post('apps/register')
  @UseGuards(ApiKeyGuard) // Only authorized admin requests can generate keys
  async registerApp(@Body() payload: CreateAppDto) {
    const appDetails = await this.oauthService.registerDeveloperApp(
      payload.name,
      payload.redirectUri,
    );

    return {
      status: 'success',
      message: 'Developer credentials generated successfully. Save the client secret safely!',
      data: appDetails,
    };
  }

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
  async exchangeToken(
    @Body('client_id') clientId: string,
    @Body('code') code: string,
    @Body('redirect_uri') redirectUri: string,
    @Body('client_secret') clientSecret?: string, // Optional to safely support Public Clients/SDKs
  ) {
    // Exchanges code and returns the sanitized user profile in a single roundtrip
    return await this.oauthService.exchangeCodeForUserProfile(
      clientId,
      code,
      redirectUri,
      clientSecret,
    );
  }
}