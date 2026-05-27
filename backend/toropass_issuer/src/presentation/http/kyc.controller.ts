import { Body, Controller, Post } from '@nestjs/common';
import { KycService } from '../../core/application/kyc.service';
import { VerifyKycDto } from './dto/verify-kyc.dto';

@Controller('v1/kyc')
export class KycController {
  constructor(private readonly kycService: KycService) {}

  @Post('verify')
  async verifyIdentity(@Body() payload: VerifyKycDto) {
    const result = await this.kycService.processKycVerification(payload);

    return {
      status: 'success',
      data: result,
    };
  }
}
