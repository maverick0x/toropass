import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config/dist/config.module';
import { ConfigService } from '@nestjs/config/dist/config.service';
import { JwtModule } from '@nestjs/jwt/dist/jwt.module';
import { WalletService } from '../../core/application/wallet.service';
import { WalletController } from '../../presentation/wallet.controller';
import { ToronetModule } from '../blockchain/toronet.module';
import { PrismaService } from '../database/prisma.service';
import { LoggerModule } from '../notifications/logger.module';

@Module({
  imports: [
    JwtModule.registerAsync({
      global: true,
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        secret: configService.get<string>('JWT_SECRET'),
      }),
    }),
    LoggerModule,
    ToronetModule,
  ],
  controllers: [WalletController],
  providers: [WalletService, PrismaService],
})
export class WalletModule {}
