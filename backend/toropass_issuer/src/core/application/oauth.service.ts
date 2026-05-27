import { BadRequestException, Injectable, UnauthorizedException } from '@nestjs/common';
import * as crypto from 'crypto';
import { PrismaService } from '../../infrastructure/database/prisma.service';

@Injectable()
export class OAuthService {
  constructor(private prisma: PrismaService) { }

  async registerDeveloperApp(name: string, redirectUri: string) {
    const clientId = 'toro_client_' + crypto.randomBytes(12).toString('hex');
    const clientSecret = 'toro_sk_' + crypto.randomBytes(32).toString('hex');

    const newApp = await this.prisma.oAuthApp.create({
      data: {
        name,
        clientId,
        clientSecret, // In production, consider hashing this like a password!
        redirectUri,
      },
    });

    return {
      id: newApp.id,
      name: newApp.name,
      clientId: newApp.clientId,
      clientSecret: newApp.clientSecret,
      redirectUri: newApp.redirectUri,
    };
  }

  // 1. Generate an authorization code after user consents (Stays the same)
  async generateAuthorizationCode(clientId: string, userId: string, redirectUri: string, scopes: string[]) {
    const app = await this.prisma.oAuthApp.findUnique({ where: { clientId } });
    if (!app || !app.isActive) {
      throw new BadRequestException('OAuth client app not found or inactive.');
    }

    if (app.redirectUri !== redirectUri) {
      throw new BadRequestException('Redirect URI mismatch.');
    }

    await this.prisma.oAuthConsent.upsert({
      where: { userId_appId: { userId, appId: app.id } },
      update: { scopes, expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000) },
      create: { userId, appId: app.id, scopes },
    });

    const code = crypto.randomBytes(24).toString('hex');
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000); // 5 minutes

    await this.prisma.oAuthCode.create({
      data: { code, appId: app.id, userId, redirectUri, expiresAt },
    });

    return code;
  }

  // 2. MERGED: Exchange authorization code directly for the verified User Profile
  async exchangeCodeForUserProfile(clientId: string, code: string, redirectUri: string, clientSecret?: string) {
    const app = await this.prisma.oAuthApp.findUnique({ where: { clientId } });
    if (!app || !app.isActive) {
      throw new UnauthorizedException('Invalid developer client ID.');
    }

    // If it's a backend server calling, they MUST provide the secret.
    // If it's your Mobile SDK calling, we rely on the strict matching of the code and redirectUri.
    if (clientSecret && app.clientSecret !== clientSecret) {
      throw new UnauthorizedException('Invalid client secret.');
    }

    // Fetch the code along with the consenting user and their active wallet
    const oauthCode = await this.prisma.oAuthCode.findUnique({
      where: { code },
      include: {
        app: true,
        user: { include: { wallets: { where: { isActive: true }, take: 1 } } }
      },
    });

    if (!oauthCode || oauthCode.app.clientId !== clientId || oauthCode.redirectUri !== redirectUri) {
      throw new BadRequestException('Invalid authorization code details.');
    }

    if (new Date() > oauthCode.expiresAt) {
      await this.prisma.oAuthCode.delete({ where: { id: oauthCode.id } }).catch(() => { });
      throw new BadRequestException('Authorization code has expired.');
    }

    // Burn the temporary code immediately so it can never be reused
    await this.prisma.oAuthCode.delete({ where: { id: oauthCode.id } });

    const user = oauthCode.user;
    const activeWallet = user.wallets[0];

    // Return the sanitized profile data immediately
    return {
      status: 'success',
      data: {
        id: user.id,
        kycVerified: user.kycVerified,
        kycAnchorHash: user.kycAnchorHash,
        wallet: activeWallet ? {
          address: activeWallet.address,
          tnsName: activeWallet.tnsName,
          network: activeWallet.network
        } : null,
      },
    };
  }
}