import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { ConsentController } from 'src/presentation/http/conscent.controller';
import { OAuthService } from '../../core/application/oauth.service';
import { OAuthController } from '../../presentation/http/oauth.controller';
import { PrismaService } from '../database/prisma.service';

@Module({
  imports: [ConfigModule],
  controllers: [OAuthController, ConsentController],
  providers: [OAuthService, PrismaService],
  exports: [OAuthService],
})
export class OAuthModule { }