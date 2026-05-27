import { Controller, Get, Headers, UnauthorizedException } from '@nestjs/common';
import { OAuthService } from '../../core/application/oauth.service';

@Controller('v1/users')
export class UserController {
  constructor(private oauthService: OAuthService) { }

  @Get('me')
  async getProfile(@Headers('authorization') authHeader: string) {
    if (!authHeader) {
      throw new UnauthorizedException('Missing Authorization Header.');
    }

    const user = await this.oauthService.verifyAccessToken(authHeader);
    const activeWallet = user.wallets[0];

    return {
      status: 'success',
      data: {
        id: user.id,
        kycVerified: user.kycVerified,
        kycAnchorHash: user.kycAnchorHash,
        wallet: activeWallet ? {
          address: activeWallet.address,
          tnsName: activeWallet.tnsName,
          network: activeWallet.network
        } : null,
      },
    };
  }
}