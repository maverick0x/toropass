import {
  CanActivate,
  ExecutionContext,
  Inject,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as crypto from 'crypto';
import { Request } from 'express';
import { ILogger, LOGGER_PORT } from '../ports/logger.interface';

type AuthenticatedDeviceRequest = Request & {
  deviceId?: string;
};

@Injectable()
export class HmacAuthGuard implements CanActivate {
  private readonly MAX_REQUEST_AGE_SECONDS = 120; // 2 minutes

  constructor(
    private configService: ConfigService,
    @Inject(LOGGER_PORT) private logger: ILogger,
  ) {}

  canActivate(context: ExecutionContext): boolean {
    const request = context
      .switchToHttp()
      .getRequest<AuthenticatedDeviceRequest>();
    const deviceId = request.get('x-device-id');
    const timestampStr = request.get('x-timestamp');
    const clientSignature = request.get('x-signature');

    if (!deviceId || !timestampStr || !clientSignature) {
      void this.logger.logAlert({
        message: 'Missing required HMAC authentication headers.',
        slack: true,
      });
      throw new UnauthorizedException(
        'Unauthorized: Missing authentication headers.',
      );
    }

    const requestTimestamp = parseInt(timestampStr, 10);
    const currentTimestamp = Math.floor(Date.now() / 1000);

    // Reject requests that are too old or come from the "future"
    if (
      Math.abs(currentTimestamp - requestTimestamp) >
      this.MAX_REQUEST_AGE_SECONDS
    ) {
      void this.logger.logAlert({
        message: `Request timestamp is invalid. Device ID: ${deviceId}, Timestamp: ${timestampStr}`,
        slack: true,
      });
      throw new UnauthorizedException(
        'Request timestamp is expired or invalid.',
      );
    }

    const appSecret = this.configService.get<string>('APP_SECRET');
    if (!appSecret) throw new Error('APP_SECRET not defined');

    // Reconstruct the signature
    const message = `${requestTimestamp}:${deviceId}`;
    const expectedSignature = crypto
      .createHmac('sha256', appSecret)
      .update(message)
      .digest('hex');

    // Use timingSafeEqual to prevent against timing attacks
    const expectedBuffer = Buffer.from(expectedSignature);
    const providedBuffer = Buffer.from(clientSignature);
    if (
      expectedBuffer.length !== providedBuffer.length ||
      !crypto.timingSafeEqual(expectedBuffer, providedBuffer)
    ) {
      void this.logger.logAlert({
        message: `HMAC signature validation failed. Device ID: ${deviceId}`,
        slack: true,
      });
      throw new UnauthorizedException('Invalid request signature.');
    }

    request.deviceId = deviceId;

    return true;
  }
}
