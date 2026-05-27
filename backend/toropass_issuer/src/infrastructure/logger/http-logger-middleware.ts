import { Injectable, Logger, NestMiddleware } from '@nestjs/common';
import { NextFunction, Request, Response } from 'express';

@Injectable()
export class HttpLoggerMiddleware implements NestMiddleware {
  private logger = new Logger('HTTP');

  use(request: Request, response: Response, next: NextFunction): void {
    const { ip, method, originalUrl } = request;
    const userAgent = request.get('user-agent') || '';
    const startTime = Date.now();

    response.on('finish', () => {
      const { statusCode } = response;
      const contentLength = response.get('content-length') || 0;
      const duration = Date.now() - startTime;

      if (statusCode >= 400) {
        this.logger.error(
          `${method} ${originalUrl} ${statusCode} ${contentLength}b - ${userAgent} ${ip} [${duration}ms]`,
        );
      } else {
        this.logger.log(
          `${method} ${originalUrl} ${statusCode} ${contentLength}b - ${userAgent} ${ip} [${duration}ms]`,
        );
      }
    });

    next();
  }
}
