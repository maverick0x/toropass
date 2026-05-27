import { BadRequestException, Injectable, UnauthorizedException } from '@nestjs/common';
import * as crypto from 'crypto';
import { PrismaService } from '../../infrastructure/database/prisma.service';

@Injectable()
export class OAuthService {
  constructor(private prisma: PrismaService) { }

  // 1. Generate an authorization code after user consents in Flutter app
  async generateAuthorizationCode(clientId: string, userId: string, redirectUri: string, scopes: string[]) {
    const app = await this.prisma.oAuthApp.findUnique({ where: { clientId } });
    if (!app || !app.isActive) {
      throw new BadRequestException('OAuth client app not found or inactive.');
    }

    // Verify redirect URI matches what they registered
    if (app.redirectUri !== redirectUri) {
      throw new BadRequestException('Redirect URI mismatch.');
    }

    // Record or update user consent
    await this.prisma.oAuthConsent.upsert({
      where: { userId_appId: { userId, appId: app.id } },
      update: { scopes, expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000) }, // 30 Days
      create: { userId, appId: app.id, scopes },
    });

    // Create a 5-minute transient code
    const code = crypto.randomBytes(24).toString('hex');
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000);

    await this.prisma.oAuthCode.create({
      data: { code, appId: app.id, userId, redirectUri, expiresAt },
    });

    return code;
  }

  // 2. Exchange authorization code for an Access Token (Called server-to-server by 3rd party)
  async exchangeCodeForToken(clientId: string, clientSecret: string, code: string, redirectUri: string) {
    const app = await this.prisma.oAuthApp.findUnique({ where: { clientId } });
    if (!app || app.clientSecret !== clientSecret || !app.isActive) {
      throw new UnauthorizedException('Invalid developer client credentials.');
    }

    const oauthCode = await this.prisma.oAuthCode.findUnique({
      where: { code },
      include: { app: true },
    });

    if (!oauthCode || oauthCode.app.clientId !== clientId || oauthCode.redirectUri !== redirectUri) {
      throw new BadRequestException('Invalid authorization code details.');
    }

    if (new Date() > oauthCode.expiresAt) {
      await this.prisma.oAuthCode.delete({ where: { id: oauthCode.id } }).catch(() => { });
      throw new BadRequestException('Authorization code has expired.');
    }

    // Generate a long-lived access token
    const accessToken = 'toro_tk_' + crypto.randomBytes(32).toString('hex');
    const tokenExpiresAt = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000); // 30 Days

    const [tokenRecord] = await this.prisma.$transaction([
      this.prisma.oAuthToken.create({
        data: { accessToken, appId: app.id, userId: oauthCode.userId, expiresAt: tokenExpiresAt },
      }),
      this.prisma.oAuthCode.delete({ where: { id: oauthCode.id } }), // Burn the code!
    ]);

    return {
      access_token: tokenRecord.accessToken,
      token_type: 'Bearer',
      expires_in: 30 * 24 * 60 * 60, // in seconds
    };
  }

  // 3. Verify access token when 3rd party hits /v1/users/me
  async verifyAccessToken(token: string) {
    const cleanedToken = token.replace('Bearer ', '').trim();
    const tokenRecord = await this.prisma.oAuthToken.findUnique({
      where: { accessToken: cleanedToken },
      include: {
        user: {
          include: { wallets: { where: { isActive: true }, take: 1 } },
        },
      },
    });

    if (!tokenRecord || new Date() > tokenRecord.expiresAt) {
      throw new UnauthorizedException('Invalid or expired developer access token.');
    }

    return tokenRecord.user;
  }
}