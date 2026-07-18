import { BadRequestException, UnauthorizedException } from '@nestjs/common';
import * as crypto from 'crypto';
import { PrismaService } from '../../infrastructure/database/prisma.service';
import { OAuthService } from './oauth.service';

const codeVerifier = 'dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk';
const codeChallenge = crypto
  .createHash('sha256')
  .update(codeVerifier)
  .digest('base64url');

describe('OAuthService security boundaries', () => {
  const app = {
    id: 'app-1',
    clientId: 'toro_client_1',
    clientSecret: 'hashed-secret',
    redirectUri: 'example://oauth/callback',
    developerId: 'developer-1',
    isActive: true,
    name: 'Example',
    createdAt: new Date(),
  };
  const user = {
    id: 'user-1',
    bvnHash: 'hash',
    password: 'hash',
    dateOfBirth: new Date(),
    kycVerified: true,
    kycAnchorHash: 'anchor',
    createdAt: new Date(),
    updatedAt: new Date(),
    wallets: [
      {
        address: '0x123',
        tnsName: 'alice',
        network: 'testnet',
      },
    ],
  };

  function createHarness() {
    const transaction = {
      oAuthConsent: {
        upsert: jest.fn(),
        findUnique: jest.fn(),
        delete: jest.fn(),
      },
      oAuthToken: {
        deleteMany: jest.fn(),
      },
      oAuthCode: {
        create: jest.fn(),
        deleteMany: jest.fn(),
      },
    };
    const prisma = {
      oAuthApp: {
        findUnique: jest.fn(),
      },
      oAuthCode: {
        findUnique: jest.fn(),
        delete: jest.fn(),
      },
      oAuthToken: {
        create: jest.fn(),
        findUnique: jest.fn(),
        delete: jest.fn(),
      },
      oAuthConsent: {
        findUnique: jest.fn(),
      },
      $transaction: jest.fn(async (operation: unknown) => {
        if (typeof operation === 'function') {
          return (
            operation as (client: typeof transaction) => Promise<unknown>
          )(transaction);
        }
        return Promise.all(operation as Promise<unknown>[]);
      }),
    };

    return {
      prisma,
      transaction,
      service: new OAuthService(prisma as unknown as PrismaService),
    };
  }

  it('rejects unsupported scopes before issuing a code', async () => {
    const { prisma, service } = createHarness();
    prisma.oAuthApp.findUnique.mockResolvedValue(app);

    await expect(
      service.generateAuthorizationCode(
        app.clientId,
        user.id,
        app.redirectUri,
        ['wallet', 'email'],
        codeChallenge,
        'S256',
      ),
    ).rejects.toBeInstanceOf(BadRequestException);
    expect(prisma.$transaction).not.toHaveBeenCalled();
  });

  it('requires the PKCE verifier and filters the profile by scope', async () => {
    const { prisma, service } = createHarness();
    const expiresAt = new Date(Date.now() + 60_000);
    const oauthCode = {
      id: 'code-1',
      code: 'authorization-code',
      appId: app.id,
      userId: user.id,
      redirectUri: app.redirectUri,
      scopes: ['kyc_status'],
      codeChallenge,
      codeChallengeMethod: 'S256',
      expiresAt,
      createdAt: new Date(),
      app,
      user,
    };
    prisma.oAuthApp.findUnique.mockResolvedValue(app);
    prisma.oAuthCode.findUnique.mockResolvedValue(oauthCode);
    prisma.oAuthConsent.findUnique.mockResolvedValue({
      id: 'consent-1',
      userId: user.id,
      appId: app.id,
      scopes: ['kyc_status'],
      grantedAt: new Date(),
      expiresAt,
    });
    prisma.oAuthToken.create.mockResolvedValue({});
    prisma.oAuthCode.delete.mockResolvedValue({});

    const result = await service.exchangeCodeForUserProfile(
      app.clientId,
      oauthCode.code,
      app.redirectUri,
      codeVerifier,
    );

    expect(result.data.profile).toEqual({
      id: user.id,
      kycVerified: true,
      kycAnchorHash: 'anchor',
    });
    const createToken = prisma.oAuthToken.create as jest.Mock<
      Promise<unknown>,
      [{ data: { scopes: string[] } }]
    >;
    expect(createToken.mock.calls[0][0].data.scopes).toEqual(['kyc_status']);

    await expect(
      service.exchangeCodeForUserProfile(
        app.clientId,
        oauthCode.code,
        app.redirectUri,
        `${codeVerifier}x`,
      ),
    ).rejects.toBeInstanceOf(UnauthorizedException);
  });

  it('invalidates a token when consent has expired', async () => {
    const { prisma, service } = createHarness();
    prisma.oAuthToken.findUnique.mockResolvedValue({
      id: 'token-1',
      accessToken: 'toro_tk_1',
      appId: app.id,
      userId: user.id,
      scopes: ['wallet'],
      expiresAt: new Date(Date.now() + 60_000),
      createdAt: new Date(),
      app,
      user,
    });
    prisma.oAuthConsent.findUnique.mockResolvedValue({
      id: 'consent-1',
      userId: user.id,
      appId: app.id,
      scopes: ['wallet'],
      grantedAt: new Date(Date.now() - 120_000),
      expiresAt: new Date(Date.now() - 60_000),
    });
    prisma.oAuthToken.delete.mockResolvedValue({});

    await expect(
      service.verifyAccessToken('Bearer toro_tk_1'),
    ).rejects.toBeInstanceOf(UnauthorizedException);
    expect(prisma.oAuthToken.delete).toHaveBeenCalledWith({
      where: { id: 'token-1' },
    });
  });

  it('rejects tokens issued to an inactive app', async () => {
    const { prisma, service } = createHarness();
    prisma.oAuthToken.findUnique.mockResolvedValue({
      id: 'token-1',
      accessToken: 'toro_tk_1',
      appId: app.id,
      userId: user.id,
      scopes: ['wallet'],
      expiresAt: new Date(Date.now() + 60_000),
      createdAt: new Date(),
      app: { ...app, isActive: false },
      user,
    });

    await expect(
      service.verifyAccessToken('Bearer toro_tk_1'),
    ).rejects.toBeInstanceOf(UnauthorizedException);
    expect(prisma.oAuthConsent.findUnique).not.toHaveBeenCalled();
  });

  it('revokes consent, codes, and tokens in one transaction', async () => {
    const { transaction, service } = createHarness();
    transaction.oAuthConsent.findUnique.mockResolvedValue({
      id: 'consent-1',
    });

    await service.revokeUserConsent(user.id, app.id);

    expect(transaction.oAuthToken.deleteMany).toHaveBeenCalledWith({
      where: { userId: user.id, appId: app.id },
    });
    expect(transaction.oAuthCode.deleteMany).toHaveBeenCalledWith({
      where: { userId: user.id, appId: app.id },
    });
    expect(transaction.oAuthConsent.delete).toHaveBeenCalledWith({
      where: { id: 'consent-1' },
    });
  });
});
