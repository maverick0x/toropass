import { Module } from '@nestjs/common';
import { WalletService } from '../../core/application/wallet.service';
import { WalletController } from '../../presentation/http/wallet.controller';
import { PrismaService } from '../database/prisma.service';
import { LoggerModule } from '../notifications/logger.module';

@Module({
  imports: [LoggerModule],
  controllers: [WalletController],
  providers: [WalletService, PrismaService],
})
export class WalletModule {}
