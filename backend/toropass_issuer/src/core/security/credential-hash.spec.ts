import {
  digestOpaqueToken,
  hashBvn,
  legacyBvnHash,
  tokenHashesMatch,
} from './credential-hash';

describe('credential hashing', () => {
  const pepper = 'a-secure-test-pepper-with-32-characters';

  it('creates deterministic versioned BVN HMACs', () => {
    const first = hashBvn('12345678901', pepper);
    const second = hashBvn(' 12345678901 ', pepper);

    expect(first).toBe(second);
    expect(first).toMatch(/^v1:[a-f0-9]{64}$/);
    expect(first).not.toContain('12345678901');
  });

  it('changes the BVN hash when the pepper changes', () => {
    expect(hashBvn('12345678901', pepper)).not.toBe(
      hashBvn('12345678901', `${pepper}-rotated`),
    );
  });

  it('keeps a tagged legacy lookup value during migration', () => {
    expect(legacyBvnHash('12345678901')).toMatch(
      /^legacy-sha256:[a-f0-9]{64}$/,
    );
  });

  it('digests opaque tokens without retaining the bearer value', () => {
    const tokenHash = digestOpaqueToken('toro_tk_secret');

    expect(tokenHash).toMatch(/^[a-f0-9]{64}$/);
    expect(tokenHash).not.toContain('toro_tk_secret');
    expect(tokenHashesMatch(tokenHash, tokenHash)).toBe(true);
    expect(tokenHashesMatch(tokenHash, digestOpaqueToken('different'))).toBe(
      false,
    );
  });
});
