import {
  Body,
  Controller,
  Delete,
  Get,
  Headers,
  Param,
  Post,
  Query,
  UnauthorizedException,
  UseGuards,
} from '@nestjs/common';
import { OAuthService } from '../core/application/oauth.service';
import { ApiKeyGuard } from '../core/guards/api-key.guard';
import { CreateAppDto } from './dto/create-app.dto';

@Controller({ path: 'oauth', version: '1' })
export class OAuthController {
  constructor(private oauthService: OAuthService) { }

  @Post('apps/register')
  @UseGuards(ApiKeyGuard)
  async registerApp(@Body() payload: CreateAppDto) {
    const appDetails = await this.oauthService.registerApp(
      payload.name,
      payload.redirectUri,
      payload.developerId,
    );

    return {
      status: 'success',
      message:
        'Application credentials generated successfully. Save the client secret safely!',
      data: appDetails,
    };
  }

  @Get('apps')
  @UseGuards(ApiKeyGuard)
  async listApps(@Query('developer_id') developerId: string) {
    const apps = await this.oauthService.getApps(developerId);
    return {
      status: 'success',
      data: apps,
    };
  }

  @Delete('apps/:appId')
  @UseGuards(ApiKeyGuard)
  async deleteApp(
    @Param('appId') appId: string,
    @Body('developer_id') developerId: string,
  ) {
    return await this.oauthService.deleteApp(developerId, appId);
  }

  @Post('authorize')
  @UseGuards(ApiKeyGuard)
  async authorize(
    @Body('client_id') clientId: string,
    @Body('user_id') userId: string,
    @Body('redirect_uri') redirectUri: string,
    @Body('scopes') scopes: string[],
  ) {
    const code = await this.oauthService.generateAuthorizationCode(
      clientId,
      userId,
      redirectUri,
      scopes,
    );
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
