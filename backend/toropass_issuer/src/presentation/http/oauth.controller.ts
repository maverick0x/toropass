import { Body, Controller, Get, Headers, Post, UnauthorizedException, UseGuards } from '@nestjs/common';
import { OAuthService } from '../../core/application/oauth.service';
import { ApiKeyGuard } from '../../core/guards/api-key.guard';
import { CreateAppDto } from './dto/create-app.dto';

@Controller({ path: 'oauth', version: '1' })
export class OAuthController {
  constructor(private oauthService: OAuthService) { }

  @Post('apps/register')
  @UseGuards(ApiKeyGuard)
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

  @Post('token')
  async exchangeToken(
    @Body('client_id') clientId: string,
    @Body('code') code: string,
    @Body('redirect_uri') redirectUri: string,
    @Body('client_secret') clientSecret?: string,
  ) {
    return await this.oauthService.exchangeCodeForUserProfile(
      clientId,
      code,
      redirectUri,
      clientSecret,
    );
  }

  @Get('profile')
  async getProfileSilently(@Headers('authorization') authHeader: string) {
    if (!authHeader) {
      throw new UnauthorizedException('Missing Authorization Header.');
    }

    return await this.oauthService.verifyAccessToken(authHeader);
  }
}