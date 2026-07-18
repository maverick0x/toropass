import { UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../../infrastructure/database/prisma.service';
import { IBlockchainPort } from '../ports/blockchain.interface';
import { ILogger } from '../ports/logger.interface';
import { digestOpaqueToken } from '../security/credential-hash';
import { RefreshTokenPayload } from './types/refresh-token-payload.type';
import { WalletService } from './wallet.service';

type CreatedSession = {
  id: string;
  userId: string;
  tokenHash: string;
  familyId: string;
  expiresAt: Date;
  refreshToken?: string;
};

type FamilyRevocation = {
  where: { familyId: string };
  data: { revokedAt: Date; reuseDetectedAt: Date };
};

type SessionClaim = {
  where: {
    id: string;
    revokedAt: null;
    reuseDetectedAt: null;
  };
  data: { revokedAt: Date; replacedById: string };
};

describe('WalletService refresh-token rotation', () => {
  const oldRefreshToken = 'signed-old-refresh-token';
  const payload: RefreshTokenPayload = {
    sub: 'user-1',
    sessionId: 'session-1',
    familyId: 'family-1',
    tokenUse: 'refresh',
  };

  function createHarness() {
    const transaction = {
      userSession: {
        findUnique: jest.fn(),
        update: jest.fn(),
        updateMany: jest.fn<
          Promise<{ count: number }>,
          [FamilyRevocation | SessionClaim]
        >(),
        create: jest.fn<Promise<unknown>, [{ data: CreatedSession }]>(),
      },
    };
    const prisma = {
      userSession: {
        create: jest.fn(),
      },
      $transaction: jest.fn(
        async (
          operation: (client: typeof transaction) => Promise<unknown>,
        ): Promise<unknown> => operation(transaction),
      ),
    };
    const jwt = {
      verifyAsync: jest.fn(),
      signAsync: jest.fn((claims: { tokenUse: string; sessionId?: string }) =>
        Promise.resolve(
          claims.tokenUse === 'access'
            ? 'signed-new-access-token'
            : `signed-new-refresh-token-${claims.sessionId}`,
        ),
      ),
    };

    return {
      transaction,
      prisma,
      jwt,
      service: new WalletService(
        prisma as unknown as PrismaService,
        jwt as unknown as JwtService,
        {} as IBlockchainPort,
        {} as ILogger,
      ),
    };
  }

  function activeSession() {
    return {
      id: payload.sessionId,
      userId: payload.sub,
      tokenHash: digestOpaqueToken(oldRefreshToken),
      familyId: payload.familyId,
      expiresAt: new Date(Date.now() + 60_000),
      revokedAt: null,
      replacedById: null,
      reuseDetectedAt: null,
      createdAt: new Date(),
    };
  }

  it('rotates a refresh token atomically and stores only its digest', async () => {
    const { transaction, jwt, service } = createHarness();
    jwt.verifyAsync.mockResolvedValue(payload);
    transaction.userSession.findUnique.mockResolvedValue(activeSession());
    transaction.userSession.updateMany.mockResolvedValue({ count: 1 });
    transaction.userSession.create.mockResolvedValue({});

    const result = await service.refreshSession(oldRefreshToken);

    expect(result.accessToken).toBe('signed-new-access-token');
    expect(result.refreshToken).toContain('signed-new-refresh-token-');
    const createCall = transaction.userSession.create.mock.calls[0]?.[0];
    expect(createCall?.data.userId).toBe(payload.sub);
    expect(createCall?.data.familyId).toBe(payload.familyId);
    expect(createCall?.data.tokenHash).toBe(
      digestOpaqueToken(result.refreshToken),
    );
    expect(createCall?.data.refreshToken).toBeUndefined();
  });

  it('revokes the token family when a revoked token is reused', async () => {
    const { transaction, jwt, service } = createHarness();
    jwt.verifyAsync.mockResolvedValue(payload);
    transaction.userSession.findUnique.mockResolvedValue({
      ...activeSession(),
      revokedAt: new Date(),
    });
    transaction.userSession.updateMany.mockResolvedValue({ count: 2 });

    await expect(service.refreshSession(oldRefreshToken)).rejects.toThrow(
      'Refresh token reuse detected',
    );
    const updateCalls = transaction.userSession.updateMany.mock.calls;
    const familyRevocation = updateCalls[updateCalls.length - 1]?.[0] as
      | FamilyRevocation
      | undefined;
    expect(familyRevocation).toBeDefined();
    if (!familyRevocation || !('familyId' in familyRevocation.where)) return;
    expect(familyRevocation.where).toEqual({ familyId: payload.familyId });
    expect(familyRevocation.data.revokedAt).toBeInstanceOf(Date);
    expect(familyRevocation.data.reuseDetectedAt).toBeInstanceOf(Date);
    expect(transaction.userSession.create).not.toHaveBeenCalled();
  });

  it('treats a lost atomic claim as reuse and revokes the family', async () => {
    const { transaction, jwt, service } = createHarness();
    jwt.verifyAsync.mockResolvedValue(payload);
    transaction.userSession.findUnique.mockResolvedValue(activeSession());
    transaction.userSession.updateMany
      .mockResolvedValueOnce({ count: 0 })
      .mockResolvedValueOnce({ count: 2 });

    await expect(
      service.refreshSession(oldRefreshToken),
    ).rejects.toBeInstanceOf(UnauthorizedException);
    const updateCalls = transaction.userSession.updateMany.mock.calls;
    const familyRevocation = updateCalls[updateCalls.length - 1]?.[0] as
      | FamilyRevocation
      | undefined;
    expect(familyRevocation).toBeDefined();
    if (!familyRevocation || !('familyId' in familyRevocation.where)) return;
    expect(familyRevocation.where).toEqual({ familyId: payload.familyId });
    expect(familyRevocation.data.revokedAt).toBeInstanceOf(Date);
    expect(familyRevocation.data.reuseDetectedAt).toBeInstanceOf(Date);
    expect(transaction.userSession.create).not.toHaveBeenCalled();
  });
});
