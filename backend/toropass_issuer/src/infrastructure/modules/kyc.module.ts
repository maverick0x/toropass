import { Module } from '@nestjs/common';
import { KycService } from '../../core/application/kyc.service';
import { KycController } from '../../presentation/http/kyc.controller';
import { ToronetModule } from '../blockchain/toronet.module';
import { PrismaService } from '../database/prisma.service';
import { LoggerModule } from '../notifications/logger.module';

@Module({
  imports: [ToronetModule, LoggerModule],
  controllers: [KycController],
  providers: [KycService, PrismaService],
})
export class KycModule {}
