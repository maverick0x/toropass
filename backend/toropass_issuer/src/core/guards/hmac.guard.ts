import {
  CanActivate,
  ExecutionContext,
  Inject,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as crypto from 'crypto';
import { ILogger, LOGGER_PORT } from '../ports/logger.interface';

@Injectable()
export class HmacAuthGuard implements CanActivate {
  private readonly MAX_REQUEST_AGE_SECONDS = 120; // 2 minutes

  constructor(
    private configService: ConfigService,
    @Inject(LOGGER_PORT) private logger: ILogger
  ) { }

  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const headers = request.headers;

    const deviceId = headers['x-device-id'];
    const timestampStr = headers['x-timestamp'];
    const clientSignature = headers['x-signature'];

    if (!deviceId || !timestampStr || !clientSignature) {
      this.logger.logAlert({
        message: 'Missing required HMAC authentication headers.',
        slack: true,
      });
      throw new UnauthorizedException('Unauthorized: Missing authentication headers.');
    }

    const requestTimestamp = parseInt(timestampStr, 10);
    const currentTimestamp = Math.floor(Date.now() / 1000);

    // Reject requests that are too old or come from the "future"
    if (
      Math.abs(currentTimestamp - requestTimestamp) >
      this.MAX_REQUEST_AGE_SECONDS
    ) {
      this.logger.logAlert({
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
    try {
      const isMatch = crypto.timingSafeEqual(
        Buffer.from(expectedSignature),
        Buffer.from(clientSignature),
      );

      if (!isMatch)
        throw new UnauthorizedException('Invalid request signature.');
    } catch (e) {
      this.logger.logAlert({
        message: `HMAC signature validation failed. Device ID: ${deviceId}`,
        slack: true,
      });
      throw new UnauthorizedException('Malformed signature.');
    }

    request.deviceId = deviceId;

    return true;
  }
}
