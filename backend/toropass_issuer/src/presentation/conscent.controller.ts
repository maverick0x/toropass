import { Controller, Delete, Get, Param, UseGuards } from '@nestjs/common';
import { OAuthService } from '../core/application/oauth.service';
import { ApiKeyGuard } from '../core/guards/api-key.guard';

@Controller({ path: 'conscents/:userId', version: '1' })
@UseGuards(ApiKeyGuard)
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
