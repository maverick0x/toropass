import {
  BadRequestException,
  Body,
  Controller,
  Get,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { CurrentUser } from 'src/core/decorators/user.decorator';
import { ApiGuard } from 'src/core/guards/api.guard';
import { AuthGuard } from 'src/core/guards/auth.guard';
import { HmacAuthGuard } from 'src/core/guards/hmac.guard';
import { User } from 'src/generated/prisma/client';
import { WalletService } from '../core/application/wallet.service';
import { ChangePasswordDto } from './dto/change-password.dto';
import { CreateWalletDto } from './dto/create-wallet.dto';
import { RefreshDto } from './dto/refresh.dto';
import { ValidateWalletDto } from './dto/validate-wallet.dto';

@Controller({ path: 'wallets', version: '1' })
@UseGuards(ApiGuard)
@UseGuards(HmacAuthGuard)
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
      data: {
        username: payload.username,
        ...result,
      },
    };
  }

  @Post('validate')
  async validateWallet(@Body() payload: ValidateWalletDto) {
    const result = await this.walletService.validateExistingWallet(
      payload.username,
      payload.password,
    );

    return {
      status: 'success',
      message: 'Wallet validated successfully.',
      data: {
        username: payload.username,
        ...result,
      },
    };
  }

  @Get()
  @UseGuards(AuthGuard)
  async getWallet(@CurrentUser() user: User) {
    const result = await this.walletService.getWalletProfile(user.id);

    return {
      status: 'success',
      message: 'Wallet retrieved successfully.',
      data: result,
    };
  }

  @Post('change-password')
  @UseGuards(AuthGuard)
  async changePassword(
    @CurrentUser() user: User,
    @Body() payload: ChangePasswordDto,
  ) {
    const result = await this.walletService.changeWalletPassword(
      user.id,
      payload.oldPassword,
      payload.newPassword,
    );

    return {
      status: 'success',
      message: result.message,
    };
  }

  @Post('refresh')
  async refreshTokens(@Body() payload: RefreshDto) {
    const tokens = await this.walletService.refreshSession(
      payload.refreshToken,
    );

    return {
      status: 'success',
      message: 'Session refreshed successfully.',
      data: tokens,
    };
  }
}
