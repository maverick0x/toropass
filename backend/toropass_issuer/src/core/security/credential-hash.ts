import * as crypto from 'crypto';

const BVN_HASH_VERSION = 'v1';

export function digestOpaqueToken(token: string): string {
  return crypto.createHash('sha256').update(token).digest('hex');
}

export function hashBvn(bvn: string, pepper: string): string {
  const normalizedBvn = normalizeBvn(bvn);
  const digest = crypto
    .createHmac('sha256', pepper)
    .update(normalizedBvn)
    .digest('hex');

  return `${BVN_HASH_VERSION}:${digest}`;
}

export function legacyBvnHash(bvn: string): string {
  const digest = crypto
    .createHash('sha256')
    .update(normalizeBvn(bvn))
    .digest('hex');

  return `legacy-sha256:${digest}`;
}

export function tokenHashesMatch(actual: string, expected: string): boolean {
  const actualBuffer = Buffer.from(actual);
  const expectedBuffer = Buffer.from(expected);

  return (
    actualBuffer.length === expectedBuffer.length &&
    crypto.timingSafeEqual(actualBuffer, expectedBuffer)
  );
}

function normalizeBvn(bvn: string): string {
  return bvn.trim();
}
