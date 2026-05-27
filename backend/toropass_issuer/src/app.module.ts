import { MiddlewareConsumer, Module, NestModule } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config/dist/config.module';
import { APP_GUARD } from '@nestjs/core';
import { ThrottlerGuard, ThrottlerModule } from '@nestjs/throttler';
import { ToronetModule } from './infrastructure/blockchain/toronet.module';
import { PrismaService } from './infrastructure/database/prisma.service';
import { HttpLoggerMiddleware } from './infrastructure/logger/http-logger-middleware';
import { KycModule } from './infrastructure/modules/kyc.module';
import { WalletModule } from './infrastructure/modules/wallet.module';
import { LoggerModule } from './infrastructure/notifications/logger.module';
import { HealthController } from './presentation/http/health.controller';

@Module({
  imports: [
    // Allow max 10 requests per 60 seconds per IP
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    ThrottlerModule.forRoot([
      {
        ttl: 60000,
        limit: 10,
      },
    ]),
    LoggerModule,
    ToronetModule,
    WalletModule,
    KycModule,
  ],
  controllers: [HealthController],
  providers: [
    PrismaService,
    {
      provide: APP_GUARD,
      useClass: ThrottlerGuard,
    },
  ],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(HttpLoggerMiddleware).forRoutes('*');
  }
}
