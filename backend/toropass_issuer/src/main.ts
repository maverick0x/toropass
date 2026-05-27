import { VersioningType } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import helmet from 'helmet';
import { getSDKConfig, initializeSDK } from 'torosdk';
import { AppModule } from './app.module';
import { ILogger, LOGGER_PORT } from './core/ports/logger.interface';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.use(helmet());

  app.enableVersioning({
    type: VersioningType.URI,
    defaultVersion: '1',
  });

  const port = process.env.PORT || 3000;
  await app.listen(port);

  const logger = app.get<ILogger>(LOGGER_PORT);
  await logger.logInfo({
    message: `🚀 ToroPass Issuer is live and listening on port ${port}!`,
  });

  initializeSDK({ network: 'mainnet' });

  const config = getSDKConfig();
  await logger.logInfo({
    message: `SDK initialized with network: ${config.getNetwork()} and base URL: ${config.getBaseURL()}`,
  });
}
bootstrap();
