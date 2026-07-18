import {
  Body,
  Controller,
  Delete,
  Get,
  Headers,
  Param,
  Post,
  UnauthorizedException,
  UseGuards,
} from '@nestjs/common';
import { CurrentUser } from 'src/core/decorators/user.decorator';
import { AuthGuard } from 'src/core/guards/auth.guard';
import { HmacAuthGuard } from 'src/core/guards/hmac.guard';
import { User } from 'src/generated/prisma/client';
import { OAuthService } from '../core/application/oauth.service';
import { ApiGuard } from '../core/guards/api.guard';
import { CreateAppDto } from './dto/create-app.dto';
import { OAuthAuthorizeDto } from './dto/oauth-authorize.dto';
import { OAuthTokenDto } from './dto/oauth-token.dto';

@Controller({ path: 'oauth', version: '1' })
export class OAuthController {
  constructor(private oauthService: OAuthService) {}

  @Post('apps/register')
  @UseGuards(ApiGuard)
  @UseGuards(AuthGuard)
  @UseGuards(HmacAuthGuard)
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
  @UseGuards(HmacAuthGuard)
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
  @UseGuards(HmacAuthGuard)
  async deleteApp(@CurrentUser() user: User, @Param('appId') appId: string) {
    return await this.oauthService.deleteApp(user.id, appId);
  }

  @Post('authorize')
  @UseGuards(ApiGuard)
  @UseGuards(AuthGuard)
  @UseGuards(HmacAuthGuard)
  async authorize(
    @CurrentUser() user: User,
    @Body() payload: OAuthAuthorizeDto,
  ) {
    const code = await this.oauthService.generateAuthorizationCode(
      payload.client_id,
      user.id,
      payload.redirect_uri,
      payload.scopes,
      payload.code_challenge,
      payload.code_challenge_method,
    );
    return { status: 'success', data: { code } };
  }

  @Post('token')
  async exchangeToken(@Body() payload: OAuthTokenDto) {
    return await this.oauthService.exchangeCodeForUserProfile(
      payload.client_id,
      payload.code,
      payload.redirect_uri,
      payload.code_verifier,
      payload.client_secret,
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
