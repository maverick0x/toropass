import { Body, Controller, Post } from '@nestjs/common';
import { WalletService } from '../../core/application/wallet.service';
import { CreateWalletDto } from './dto/create-wallet.dto';

@Controller('v1/wallets')
export class WalletController {
  constructor(private readonly walletService: WalletService) {}

  @Post('create')
  async createWallet(@Body() payload: CreateWalletDto) {
    const result = await this.walletService.provisionNewWallet(
      payload.username,
      payload.password,
    );

    return {
      status: 'success',
      message: 'Toronet wallet and TNS name claimed successfully.',
      data: result,
    };
  }
}
