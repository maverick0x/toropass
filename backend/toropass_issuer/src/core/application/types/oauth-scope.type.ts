import { BadRequestException } from '@nestjs/common';

export const OAUTH_SCOPES = ['kyc_status', 'wallet'] as const;

export type OAuthScope = (typeof OAUTH_SCOPES)[number];

export function normalizeOAuthScopes(scopes: string[]): OAuthScope[] {
  const normalizedScopes = [
    ...new Set(scopes.map((scope) => scope.trim()).filter(Boolean)),
  ];
  const unsupportedScopes = normalizedScopes.filter(
    (scope) => !OAUTH_SCOPES.includes(scope as OAuthScope),
  );

  if (normalizedScopes.length === 0 || unsupportedScopes.length > 0) {
    throw new BadRequestException(
      unsupportedScopes.length > 0
        ? `Unsupported OAuth scopes: ${unsupportedScopes.join(', ')}.`
        : 'At least one OAuth scope is required.',
    );
  }

  return normalizedScopes as OAuthScope[];
}

export function scopesCover(
  grantedScopes: string[],
  requiredScopes: string[],
): boolean {
  const granted = new Set(grantedScopes);
  return requiredScopes.every((scope) => granted.has(scope));
}
