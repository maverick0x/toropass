import {
  Body,
  Controller,
  Delete,
  Get,
  Headers,
  Param,
  Post,
  UnauthorizedException,
  UseGuards
} from '@nestjs/common';
import { CurrentUser } from 'src/core/decorators/user.decorator';
import { AuthGuard } from 'src/core/guards/auth.guard';
import { User } from 'src/generated/prisma/client';
import { OAuthService } from '../core/application/oauth.service';
import { ApiGuard } from '../core/guards/api.guard';
import { CreateAppDto } from './dto/create-app.dto';

@Controller({ path: 'oauth', version: '1' })
export class OAuthController {
  constructor(private oauthService: OAuthService) { }

  @Post('apps/register')
  @UseGuards(ApiGuard)
  @UseGuards(AuthGuard)
  async registerApp(@CurrentUser() user: User, @Body() payload: CreateAppDto) {
    const appDetails = await this.oauthService.registerApp(
      payload.name,
      payload.redirectUri,
      user.id,
    );

    return {
      status: 'success',
      message:
        'Application credentials generated successfully. Save the client secret safely!',
      data: appDetails,
    };
  }

  @Get('apps')
  @UseGuards(ApiGuard)
  @UseGuards(AuthGuard)
  async listApps(@CurrentUser() user: User) {
    const apps = await this.oauthService.getApps(user.id);
    return {
      status: 'success',
      data: apps,
    };
  }

  @Delete('apps/:appId')
  @UseGuards(ApiGuard)
  @UseGuards(AuthGuard)
  async deleteApp(
    @CurrentUser() user: User,
    @Param('appId') appId: string,
  ) {
    return await this.oauthService.deleteApp(user.id, appId);
  }

  @Post('authorize')
  @UseGuards(ApiGuard)
  @UseGuards(AuthGuard)
  async authorize(
    @CurrentUser() user: User,
    @Body('client_id') clientId: string,
    @Body('redirect_uri') redirectUri: string,
    @Body('scopes') scopes: string[],
  ) {
    const code = await this.oauthService.generateAuthorizationCode(
      clientId,
      user.id,
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
