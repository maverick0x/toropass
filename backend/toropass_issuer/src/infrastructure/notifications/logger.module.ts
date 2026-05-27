import { Global, Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { LOGGER_PORT } from '../../core/ports/logger.interface';
import { SlackLoggerAdapter } from './slack.adapter';

@Global()
@Module({
  imports: [ConfigModule],
  providers: [
    {
      provide: LOGGER_PORT,
      useClass: SlackLoggerAdapter,
    },
  ],
  exports: [LOGGER_PORT],
})
export class LoggerModule { }