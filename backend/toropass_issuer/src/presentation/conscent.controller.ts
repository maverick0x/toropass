import { Controller, Delete, Get, Param, UseGuards } from '@nestjs/common';
import { CurrentUser } from 'src/core/decorators/user.decorator';
import { AuthGuard } from 'src/core/guards/auth.guard';
import { HmacAuthGuard } from 'src/core/guards/hmac.guard';
import { User } from 'src/generated/prisma/client';
import { OAuthService } from '../core/application/oauth.service';
import { ApiGuard } from '../core/guards/api.guard';

@Controller({ path: 'conscents', version: '1' })
@UseGuards(ApiGuard)
@UseGuards(AuthGuard)
@UseGuards(HmacAuthGuard)
export class ConsentController {
  constructor(private oauthService: OAuthService) {}

  @Get()
  async getConsents(@CurrentUser() user: User) {
    const consents = await this.oauthService.getUserConsents(user.id);
    return {
      status: 'success',
      data: consents,
    };
  }

  @Delete(':appId')
  async revokeConsent(
    @CurrentUser() user: User,
    @Param('appId') appId: string,
  ) {
    const result = await this.oauthService.revokeUserConsent(user.id, appId);
    return {
      status: 'success',
      message: result.message,
    };
  }
}
