import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Request } from 'express';

@Injectable()
export class ApiGuard implements CanActivate {
  constructor(private configService: ConfigService) {}

  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest<Request>();
    const providedKey = request.get('x-api-key');
    const validKey = this.configService.get<string>('APP_API_KEY');

    if (!validKey) {
      throw new UnauthorizedException();
    }

    if (!providedKey || providedKey !== validKey) {
      throw new UnauthorizedException();
    }

    return true;
  }
}
