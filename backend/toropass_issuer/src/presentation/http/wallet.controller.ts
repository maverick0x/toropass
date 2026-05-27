import {
  BadRequestException,
  Body,
  Controller,
  Get,
  Post,
  Query,
} from '@nestjs/common';
import { WalletService } from '../../core/application/wallet.service';
import { CreateWalletDto } from './dto/create-wallet.dto';

@Controller({ path: 'wallets', version: '1' })
export class WalletController {
  constructor(private readonly walletService: WalletService) {}

  @Get('tns')
  async checkTnsAvailability(@Query('username') username: string) {
    if (!username) {
      throw new BadRequestException('You must provide a username to check.');
    }

    const normalizedUsername = username.toLowerCase().trim();

    const isAvailable =
      await this.walletService.checkTnsAvailability(normalizedUsername);

    return {
      status: 'success',
      data: {
        username: normalizedUsername,
        isAvailable: isAvailable,
        message: isAvailable
          ? 'Username is available!'
          : 'Username is already taken.',
      },
    };
  }

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
