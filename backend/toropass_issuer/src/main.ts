import { ValidationPipe, VersioningType } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import helmet from 'helmet';
import { AppModule } from './app.module';
import { ILogger, LOGGER_PORT } from './core/ports/logger.interface';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.use(helmet());
  app.setGlobalPrefix('api', { exclude: ['api/*path'] });
  app.enableVersioning({
    type: VersioningType.URI,
    defaultVersion: '1',
  });

  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));

  const port = process.env.PORT || 3000;
  await app.listen(port);

  const logger = app.get<ILogger>(LOGGER_PORT);
  void logger.logInfo({
    message: `🚀 ToroPass Issuer is live and listening on port ${port}!`,
  });
}
void bootstrap();
