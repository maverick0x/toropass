import { Body, Controller, Post, UseGuards } from '@nestjs/common';
import { ApiGuard } from 'src/core/guards/api.guard';
import { AuthGuard } from 'src/core/guards/auth.guard';
import { KycService } from '../core/application/kyc.service';
import { VerifyKycDto } from './dto/verify-kyc.dto';

@Controller({ path: 'kyc', version: '1' })
@UseGuards(ApiGuard)
@UseGuards(AuthGuard)
// @UseGuards(HmacAuthGuard)
export class KycController {
  constructor(private readonly kycService: KycService) { }

  @Post('verify')
  async verifyIdentity(@Body() payload: VerifyKycDto) {
    const result = await this.kycService.processKycVerification(payload);

    return {
      status: 'success',
      data: result,
    };
  }
}
