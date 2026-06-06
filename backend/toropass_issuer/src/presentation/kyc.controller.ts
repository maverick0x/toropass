import { Body, Controller, Post, UseGuards } from '@nestjs/common';
import { CurrentUser } from 'src/core/decorators/user.decorator';
import { ApiGuard } from 'src/core/guards/api.guard';
import { AuthGuard } from 'src/core/guards/auth.guard';
import { HmacAuthGuard } from 'src/core/guards/hmac.guard';
import { KycService } from '../core/application/kyc.service';
import { VerifyKycDto } from './dto/verify-kyc.dto';

@Controller({ path: 'kyc', version: '1' })
@UseGuards(ApiGuard)
@UseGuards(AuthGuard)
@UseGuards(HmacAuthGuard)
export class KycController {
  constructor(private readonly kycService: KycService) { }

  @Post('verify')
  async verifyIdentity(@CurrentUser() user: any, @Body() payload: VerifyKycDto) {
    const result = await this.kycService.processKycVerification(user.id, payload);

    return {
      status: 'success',
      data: result,
    };
  }
}
