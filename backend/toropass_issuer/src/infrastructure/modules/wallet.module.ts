import { Module } from '@nestjs/common';
import { WalletService } from '../../core/application/wallet.service';
import { WalletController } from '../../presentation/wallet.controller';
import { ToronetModule } from '../blockchain/toronet.module';
import { PrismaService } from '../database/prisma.service';
import { LoggerModule } from '../notifications/logger.module';

@Module({
  imports: [LoggerModule, ToronetModule],
  controllers: [WalletController],
  providers: [WalletService, PrismaService],
})
export class WalletModule { }
