import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Request } from 'express';
import { PrismaService } from '../../infrastructure/database/prisma.service';

type AuthenticatedRequest = Request & { user?: unknown };

@Injectable()
export class AuthGuard implements CanActivate {
  constructor(
    private jwtService: JwtService,
    private prisma: PrismaService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest<AuthenticatedRequest>();
    const authHeader = request.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new UnauthorizedException(
        'Missing or invalid Authorization header.',
      );
    }

    const token = authHeader.slice('Bearer '.length);

    try {
      const payload = await this.jwtService.verifyAsync<{
        sub: string;
        tokenUse?: string;
      }>(token);
      if (payload.tokenUse !== 'access') {
        throw new UnauthorizedException('Invalid token type.');
      }
      const user = await this.prisma.user.findUnique({
        where: { id: payload.sub },
        include: { wallets: { where: { isActive: true }, take: 1 } },
      });

      if (!user) {
        throw new UnauthorizedException('User account no longer exists.');
      }

      request.user = user;

      return true;
    } catch {
      throw new UnauthorizedException('Invalid or expired access token.');
    }
  }
}
