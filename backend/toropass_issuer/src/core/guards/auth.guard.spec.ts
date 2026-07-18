import { UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ExecutionContext } from '@nestjs/common/interfaces';
import { PrismaService } from '../../infrastructure/database/prisma.service';
import { AuthGuard } from './auth.guard';

describe('AuthGuard token-purpose enforcement', () => {
  it('rejects a valid refresh JWT when used as an access token', async () => {
    const jwt = {
      verifyAsync: jest.fn().mockResolvedValue({
        sub: 'user-1',
        tokenUse: 'refresh',
      }),
    };
    const prisma = {
      user: { findUnique: jest.fn() },
    };
    const request = {
      headers: { authorization: 'Bearer refresh-token' },
    };
    const context = {
      switchToHttp: () => ({
        getRequest: () => request,
      }),
    } as unknown as ExecutionContext;
    const guard = new AuthGuard(
      jwt as unknown as JwtService,
      prisma as unknown as PrismaService,
    );

    await expect(guard.canActivate(context)).rejects.toBeInstanceOf(
      UnauthorizedException,
    );
    expect(prisma.user.findUnique).not.toHaveBeenCalled();
  });
});
