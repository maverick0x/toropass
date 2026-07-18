import {
  BadRequestException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import * as crypto from 'crypto';
import { User } from 'src/generated/prisma/client';
import { PrismaService } from '../../infrastructure/database/prisma.service';
import { digestOpaqueToken } from '../security/credential-hash';
import {
  normalizeOAuthScopes,
  OAuthScope,
  scopesCover,
} from './types/oauth-scope.type';
import { WalletProfile } from './types/wallet-profile.type';

@Injectable()
export class OAuthService {
  constructor(private prisma: PrismaService) {}

  async registerApp(name: string, redirectUri: string, developerId: string) {
    const clientId = 'toro_client_' + crypto.randomBytes(12).toString('hex');
    const plainTextSecret = 'toro_sk_' + crypto.randomBytes(32).toString('hex');

    const saltRounds = 10;
    const hashedSecret = await bcrypt.hash(plainTextSecret, saltRounds);

    const newApp = await this.prisma.oAuthApp.create({
      data: {
        name,
        clientId,
        clientSecret: hashedSecret,
        redirectUri,
        developerId,
      },
    });

    return {
      id: newApp.id,
      name: newApp.name,
      clientId: newApp.clientId,
      clientSecret: plainTextSecret,
      redirectUri: newApp.redirectUri,
    };
  }

  async getApps(developerId: string) {
    return await this.prisma.oAuthApp.findMany({
      where: { developerId },
      select: {
        id: true,
        name: true,
        clientId: true,
        redirectUri: true,
        isActive: true,
        createdAt: true,
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async deleteApp(developerId: string, appId: string) {
    const app = await this.prisma.oAuthApp.findFirst({
      where: { id: appId, developerId },
    });

    if (!app) {
      throw new BadRequestException(
        'Application not found or unauthorized access.',
      );
    }

    await this.prisma.oAuthApp.delete({
      where: { id: appId },
    });

    return { success: true, message: 'Application successfully deleted.' };
  }

  async generateAuthorizationCode(
    clientId: string,
    userId: string,
    redirectUri: string,
    scopes: string[],
    codeChallenge: string,
    codeChallengeMethod: 'S256',
  ) {
    const app = await this.prisma.oAuthApp.findUnique({ where: { clientId } });
    if (!app || !app.isActive) {
      throw new BadRequestException('OAuth client app not found or inactive.');
    }

    if (app.redirectUri !== redirectUri) {
      throw new BadRequestException('Redirect URI mismatch.');
    }

    const grantedScopes = normalizeOAuthScopes(scopes);
    const code = crypto.randomBytes(24).toString('hex');
    const codeExpiresAt = new Date(Date.now() + 5 * 60 * 1000);
    const consentExpiresAt = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);

    await this.prisma.$transaction(async (transaction) => {
      await transaction.oAuthConsent.upsert({
        where: { userId_appId: { userId, appId: app.id } },
        update: {
          scopes: grantedScopes,
          expiresAt: consentExpiresAt,
        },
        create: {
          userId,
          appId: app.id,
          scopes: grantedScopes,
          expiresAt: consentExpiresAt,
        },
      });

      // A new grant replaces older scope snapshots and pending handshakes.
      await transaction.oAuthToken.deleteMany({
        where: { userId, appId: app.id },
      });
      await transaction.oAuthCode.deleteMany({
        where: { userId, appId: app.id },
      });
      await transaction.oAuthCode.create({
        data: {
          code,
          appId: app.id,
          userId,
          redirectUri,
          scopes: grantedScopes,
          codeChallenge,
          codeChallengeMethod,
          expiresAt: codeExpiresAt,
        },
      });
    });

    return code;
  }

  async exchangeCodeForUserProfile(
    clientId: string,
    code: string,
    redirectUri: string,
    codeVerifier: string,
    clientSecret?: string,
  ) {
    const app = await this.prisma.oAuthApp.findUnique({ where: { clientId } });
    if (!app || !app.isActive) {
      throw new UnauthorizedException('Invalid developer client ID.');
    }

    // If a clientSecret is provided (Server-to-Server flow), verify against the hash
    if (clientSecret) {
      const isSecretValid = await bcrypt.compare(
        clientSecret,
        app.clientSecret,
      );
      if (!isSecretValid) {
        throw new UnauthorizedException('Invalid client secret.');
      }
    }

    const oauthCode = await this.prisma.oAuthCode.findUnique({
      where: { code },
      include: {
        app: true,
        user: { include: { wallets: { where: { isActive: true }, take: 1 } } },
      },
    });

    if (
      !oauthCode ||
      oauthCode.app.clientId !== clientId ||
      oauthCode.redirectUri !== redirectUri
    ) {
      throw new BadRequestException('Invalid authorization code details.');
    }

    if (new Date() > oauthCode.expiresAt) {
      await this.prisma.oAuthCode
        .delete({ where: { id: oauthCode.id } })
        .catch(() => {});
      throw new BadRequestException('Authorization code has expired.');
    }

    if (
      oauthCode.codeChallengeMethod !== 'S256' ||
      !this.isValidCodeVerifier(codeVerifier, oauthCode.codeChallenge)
    ) {
      throw new UnauthorizedException('Invalid PKCE code verifier.');
    }

    const consent = await this.prisma.oAuthConsent.findUnique({
      where: {
        userId_appId: {
          userId: oauthCode.userId,
          appId: oauthCode.appId,
        },
      },
    });
    const now = new Date();

    if (
      !consent ||
      !consent.expiresAt ||
      consent.expiresAt <= now ||
      !scopesCover(consent.scopes, oauthCode.scopes)
    ) {
      await this.prisma.oAuthCode
        .delete({ where: { id: oauthCode.id } })
        .catch(() => {});
      throw new UnauthorizedException(
        'The user consent has expired, changed, or been revoked.',
      );
    }

    const accessToken = 'toro_tk_' + crypto.randomBytes(32).toString('hex');
    const tokenHash = digestOpaqueToken(accessToken);
    const tokenExpiresAt = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);

    await this.prisma.$transaction([
      this.prisma.oAuthToken.create({
        data: {
          tokenHash,
          appId: app.id,
          userId: oauthCode.userId,
          scopes: oauthCode.scopes,
          expiresAt: tokenExpiresAt,
        },
      }),
      this.prisma.oAuthCode.delete({ where: { id: oauthCode.id } }), // Burn the code
    ]);

    const user = oauthCode.user;
    const profile = this.buildWalletProfile(user, oauthCode.scopes);

    return {
      status: 'success',
      data: {
        accessToken,
        profile,
      },
    };
  }

  // New Method: Verify the silent background request
  async verifyAccessToken(token: string) {
    const cleanedToken = token.replace('Bearer ', '').trim();
    const tokenHash = digestOpaqueToken(cleanedToken);

    // Find the token, make sure the consent wasn't revoked, and get the user
    const tokenRecord = await this.prisma.oAuthToken.findUnique({
      where: { tokenHash },
      include: {
        app: true,
        user: {
          include: { wallets: { where: { isActive: true }, take: 1 } },
        },
      },
    });

    if (
      !tokenRecord ||
      !tokenRecord.app.isActive ||
      new Date() > tokenRecord.expiresAt
    ) {
      throw new UnauthorizedException('Invalid or expired access token.');
    }

    // Check if the user manually revoked consent for this specific app
    const consent = await this.prisma.oAuthConsent.findUnique({
      where: {
        userId_appId: { userId: tokenRecord.userId, appId: tokenRecord.appId },
      },
    });

    if (
      !consent ||
      !consent.expiresAt ||
      consent.expiresAt <= new Date() ||
      !scopesCover(consent.scopes, tokenRecord.scopes)
    ) {
      await this.prisma.oAuthToken.delete({ where: { id: tokenRecord.id } });
      throw new UnauthorizedException(
        'Access has expired, changed, or been revoked by the user.',
      );
    }

    const user = tokenRecord.user;

    return {
      status: 'success',
      data: this.buildWalletProfile(user, tokenRecord.scopes),
    };
  }

  // =========================================================================
  // USER CONSENT MANAGEMENT
  // =========================================================================

  // Fetch all apps a user has granted access to
  async getUserConsents(userId: string) {
    const consents = await this.prisma.oAuthConsent.findMany({
      where: { userId },
      include: {
        app: {
          select: { id: true, name: true, redirectUri: true },
        },
      },
      orderBy: { grantedAt: 'desc' },
    });

    const now = new Date();

    // Filter out expired consents and map to a clean frontend DTO
    return consents
      .filter((c) => !c.expiresAt || c.expiresAt > now)
      .map((c) => ({
        appId: c.app.id,
        appName: c.app.name,
        scopes: c.scopes,
        grantedAt: c.grantedAt,
        expiresAt: c.expiresAt,
      }));
  }

  // Revoke a specific app's access
  async revokeUserConsent(userId: string, appId: string) {
    await this.prisma.$transaction(async (transaction) => {
      const consent = await transaction.oAuthConsent.findUnique({
        where: { userId_appId: { userId, appId } },
      });

      if (!consent) {
        throw new BadRequestException(
          'Consent record not found or already revoked.',
        );
      }

      await transaction.oAuthToken.deleteMany({ where: { userId, appId } });
      await transaction.oAuthCode.deleteMany({ where: { userId, appId } });
      await transaction.oAuthConsent.delete({ where: { id: consent.id } });
    });

    return { success: true, message: 'Access revoked successfully.' };
  }

  private buildWalletProfile(
    user: User & {
      wallets: Array<{
        address: string;
        tnsName: string | null;
        network: string;
      }>;
    },
    scopes: string[],
  ): WalletProfile {
    const activeWallet = user.wallets[0] ?? null;
    const grantedScopes = new Set(scopes as OAuthScope[]);

    return {
      id: user.id,
      ...(grantedScopes.has('kyc_status')
        ? {
            kycVerified: user.kycVerified,
            kycAnchorHash: user.kycAnchorHash,
          }
        : {}),
      ...(grantedScopes.has('wallet')
        ? {
            wallet: activeWallet
              ? {
                  address: activeWallet.address,
                  tnsName: activeWallet.tnsName,
                  network: activeWallet.network,
                }
              : null,
          }
        : {}),
    };
  }

  private isValidCodeVerifier(
    codeVerifier: string,
    expectedChallenge: string,
  ): boolean {
    const actualChallenge = crypto
      .createHash('sha256')
      .update(codeVerifier)
      .digest('base64url');
    const actualBuffer = Buffer.from(actualChallenge);
    const expectedBuffer = Buffer.from(expectedChallenge);

    return (
      actualBuffer.length === expectedBuffer.length &&
      crypto.timingSafeEqual(actualBuffer, expectedBuffer)
    );
  }
}
