import { Controller, Delete, Get, Param, UseGuards } from '@nestjs/common';
import { HmacAuthGuard } from 'src/core/guards/hmac.guard';
import { OAuthService } from '../core/application/oauth.service';
import { ApiGuard } from '../core/guards/api.guard';

@Controller({ path: 'conscents/:userId', version: '1' })
@UseGuards(ApiGuard)
@UseGuards(HmacAuthGuard)
export class ConsentController {
  constructor(private oauthService: OAuthService) { }

  @Get()
  async getConsents(@Param('userId') userId: string) {
    const consents = await this.oauthService.getUserConsents(userId);
    return {
      status: 'success',
      data: consents,
    };
  }

  @Delete(':appId')
  async revokeConsent(
    @Param('userId') userId: string,
    @Param('appId') appId: string,
  ) {
    const result = await this.oauthService.revokeUserConsent(userId, appId);
    return {
      status: 'success',
      message: result.message,
    };
  }
}
