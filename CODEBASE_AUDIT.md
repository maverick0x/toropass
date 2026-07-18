# ToroPass Codebase Audit

Audit date: July 18, 2026

## Scope

This audit covers:

- `apps/toropass_wallet`
- `backend/toropass_issuer`
- `packages/toropass_client`
- repository release and deployment configuration

The audit focused on security, correctness, release reliability, test coverage,
and developer experience.

## Remediation Status

Phase 1 was completed on July 18, 2026:

- OAuth authorization codes now require S256 PKCE.
- Requested scopes are validated, snapshotted, and enforced on profile fields.
- Token use now requires an active app and current, scope-covering consent.
- Reauthorizing or revoking consent invalidates related codes and tokens in a
  database transaction.

The included migration deliberately invalidates legacy OAuth codes and access
tokens because they have no trustworthy PKCE or scope snapshot. Existing wallet
login sessions are not affected. The remaining findings are still open unless
marked otherwise.

## Priority Summary

| Priority | Issue |
| --- | --- |
| High | Mobile app embeds shared backend authentication secrets |
| High | Public OAuth authorization flow does not use PKCE |
| High | Granted OAuth scopes are not enforced when returning profile data |
| High | Expired consent and inactive apps are not fully enforced |
| Medium | BVNs use an unsalted SHA-256 hash |
| Medium | Android release builds can silently use debug signing |
| Medium | Tests, linting, and CI quality gates are incomplete or failing |
| Medium | Deployment dependencies and actions are not fully reproducible |
| Low | Wallet assets and published package metadata are inconsistent |

---

## 1. Shared Secrets Are Embedded in the Wallet APK

**Severity:** High

### Evidence

- `apps/toropass_wallet/pubspec.yaml` includes `.env` as a Flutter asset.
- `hmac_provider.dart` reads `APP_SECRET` from that bundled environment file.
- `auth_interceptor.dart` sends `APP_API_KEY` with every protected request.
- The HMAC message contains only the timestamp and device ID.

Flutter assets are packaged into the final application and can be extracted.
Therefore, neither `APP_SECRET` nor `APP_API_KEY` can be considered secret after
the APK is distributed.

Because the signature does not include the HTTP method, path, query, or body, a
captured signature can also be reused for another request during the accepted
timestamp window.

### Impact

An attacker can extract the shared credentials from the APK and call endpoints
that are intended to be wallet-only. The current HMAC and API-key guards provide
limited request filtering but do not establish that a request came from a
trusted, uncompromised ToroPass Wallet.

### Recommended Fix

1. Remove `APP_SECRET` and `APP_API_KEY` from the wallet `.env` file.
2. Remove `.env` from the Flutter asset list.
3. Do not replace them with another static secret in Dart, native code, or
   obfuscated application resources.
4. Use authenticated user sessions for user-specific endpoints.
5. Use Android Play Integrity and Apple App Attest/DeviceCheck when application
   attestation is required.
6. Issue short-lived, server-generated device or installation credentials only
   after successful attestation.
7. For signed requests, bind the signature to:
   - HTTP method
   - canonical path
   - canonical query string
   - timestamp
   - nonce
   - hash of the request body
8. Store used nonces server-side for the duration of the allowed request window
   to prevent replay.
9. Apply strict rate limits to unauthenticated wallet onboarding endpoints.

### Verification

- Extracting the APK does not reveal a reusable backend API key or HMAC secret.
- Replaying an old signed request is rejected.
- Changing the method, path, query, or body invalidates the signature.
- User-specific endpoints require a valid authenticated session.

---

## 2. OAuth Authorization Code Flow Does Not Use PKCE

**Severity:** High

**Status:** Resolved in Phase 1. Deployment requires the included Prisma
migration and third-party clients must upgrade to `toropass_client` `0.2.0`.

### Evidence

- `OAuthService.exchangeCodeForUserProfile()` accepts an optional
  `clientSecret`.
- Public Flutter clients can exchange a code using only `client_id`, code, and
  redirect URI.
- `toropass_client` generates a state value but does not generate a PKCE
  verifier or challenge.

OAuth state protects against request forgery, but it does not protect an
authorization code intercepted through a custom URL scheme.

### Impact

Another mobile application registered for the same callback scheme may intercept
the callback and redeem the authorization code before the legitimate app.

### Recommended Fix

1. Generate a cryptographically random `code_verifier` in `toropass_client`.
2. Derive an S256 `code_challenge`:

   ```text
   BASE64URL(SHA256(code_verifier))
   ```

3. Include these authorization parameters:
   - `code_challenge`
   - `code_challenge_method=S256`
4. Store the challenge with the `OAuthCode` record.
5. Require `code_verifier` at the token endpoint for public clients.
6. Hash the submitted verifier and compare it to the stored challenge.
7. Burn the authorization code atomically after successful verification.
8. Reject public-client exchanges that omit PKCE.
9. Keep client-secret authentication only for confidential server-side clients.
10. Prefer Android App Links and iOS Universal Links where possible because they
    provide stronger callback ownership than custom schemes.

### Data Model Changes

Add fields such as:

```prisma
model OAuthCode {
  // Existing fields...
  codeChallenge       String @map("code_challenge")
  codeChallengeMethod String @default("S256") @map("code_challenge_method")
}
```

### Verification

- A code cannot be exchanged without its original verifier.
- A wrong verifier is rejected.
- A verifier cannot be reused after the code is burned.
- Existing state-mismatch tests continue to pass.
- Add tests that simulate callback interception and failed verifier exchange.

---

## 3. OAuth Scopes Are Recorded but Not Enforced

**Severity:** High

**Status:** Resolved in Phase 1. The issuer, wallet permission request, and
client profile model now share the `kyc_status` and `wallet` contract.

### Evidence

The issuer records requested scopes in `OAuthConsent`, but
`buildWalletProfile()` always returns:

- user ID
- KYC verification status
- KYC anchor hash
- wallet address
- TNS name
- network

The same profile is returned during initial code exchange and subsequent profile
requests regardless of the scopes granted by the user.

### Impact

An application requesting only `kyc_status` can receive wallet identity data.
This violates the permission model shown to users and weakens consent privacy.

### Recommended Fix

1. Define an authoritative scope registry in the issuer:

   ```ts
   const supportedScopes = ['kyc_status', 'wallet'] as const;
   ```

2. Validate requested scopes before presenting or granting consent.
3. Reject unknown scopes instead of storing arbitrary strings.
4. Store the granted scopes with the authorization code or resolve them through
   the consent during exchange.
5. Store the effective scopes with each access token.
6. Change `buildWalletProfile()` to accept granted scopes.
7. Return only fields covered by those scopes:
   - `kyc_status`: KYC status and, if explicitly intended, anchor hash
   - `wallet`: wallet address, TNS name, and network
8. Ensure the permission screen uses the same scope registry and descriptions.
9. Document exactly which fields each scope grants.

### Suggested Shape

```ts
private buildWalletProfile(user: UserWithWallet, scopes: string[]) {
  const profile: Record<string, unknown> = { id: user.id };

  if (scopes.includes('kyc_status')) {
    profile.kycVerified = user.kycVerified;
    profile.kycAnchorHash = user.kycAnchorHash;
  }

  if (scopes.includes('wallet')) {
    profile.wallet = this.buildWallet(user);
  }

  return profile;
}
```

The implementation syntax can differ, but the response must be constructed from
the effective granted scopes.

### Verification

- A `kyc_status`-only token cannot access wallet fields.
- A `wallet`-only token cannot access KYC fields.
- Unknown scopes are rejected.
- Updated consent replaces or deliberately merges old scopes according to a
  documented policy.

---

## 4. Consent Expiration and App Status Are Not Fully Enforced

**Severity:** High

**Status:** Resolved in Phase 1. Expired or reduced consent and inactive apps
are rejected; consent replacement and revocation invalidate related credentials
transactionally.

### Evidence

`verifyAccessToken()` verifies that:

- the access token exists
- the access token is not expired
- a consent record exists

It does not verify that:

- the consent has not expired
- the OAuth app is still active
- the token scopes are still covered by the latest consent

### Impact

An access token can continue returning profile information after the user's
consent expiration date. Tokens associated with a disabled application may also
remain usable.

### Recommended Fix

1. Reject access when `consent.expiresAt <= now`.
2. Reject access when `tokenRecord.app.isActive` is false.
3. Compare token scopes against current consent scopes.
4. Delete or revoke affected tokens when:
   - consent expires
   - consent is revoked
   - an app is disabled or deleted
   - granted scopes are reduced
5. Add a token revocation timestamp or `revokedAt` column if auditability is
   required.
6. Perform consent deletion and token invalidation in one database transaction.
7. Consider a scheduled cleanup job for expired codes, consents, sessions, and
   tokens.

### Verification

- An expired consent immediately causes profile access to return `401`.
- Disabling an app invalidates its existing access tokens.
- Revocation deletes or invalidates every token for that user/app pair.
- Reducing scopes prevents old tokens from retaining broader access.

---

## 5. BVNs Use an Unsalted SHA-256 Hash

**Severity:** Medium

### Evidence

`KycService` stores:

```ts
sha256(bvn)
```

A BVN is a fixed-format, low-entropy identifier. A raw hash does not provide
strong protection against enumeration if the database is leaked.

### Impact

An attacker with database access can generate candidate BVNs, hash them, and
compare the results with stored values.

### Recommended Fix

If only equality and uniqueness checks are required:

1. Store `HMAC-SHA-256(serverPepper, normalizedBvn)`.
2. Keep the pepper in a managed secret store, not in the database or repository.
3. Normalize the BVN before hashing.
4. Version the hash format so the pepper or algorithm can be rotated.

Example stored format:

```text
v1:<hex-hmac>
```

If the original value must be recovered:

1. Use authenticated encryption such as AES-256-GCM.
2. Store encryption keys in a managed KMS.
3. Restrict decryption access to the smallest possible service boundary.

### Migration Consideration

Existing raw hashes cannot be converted without receiving the original BVN
again. Support both formats temporarily and migrate users during their next
successful identity verification.

### Verification

- Identical BVNs still produce a stable lookup value within the service.
- The database alone is insufficient to test candidate BVNs.
- Logs, alerts, and error payloads never contain the raw BVN.

---

## 6. Android Release Builds Can Use Debug Signing

**Severity:** Medium

### Evidence

The release build selects the debug signing configuration when
`android/key.properties` does not exist.

### Impact

A release artifact can be produced with the wrong signing identity without the
build failing. This can prevent upgrades, weaken release provenance, and cause
different environments to distribute incompatible APKs.

### Recommended Fix

1. Remove the debug-signing fallback from the release build type.
2. Throw a Gradle error when release signing properties are absent.
3. Validate all required properties:
   - `storeFile`
   - `storePassword`
   - `keyAlias`
   - `keyPassword`
4. Keep `key.properties` and keystores ignored by Git.
5. Store CI signing material in GitHub Actions secrets.
6. Reconstruct the keystore during CI and delete it after the build.
7. Record the release certificate fingerprint in release documentation.

### Verification

- `flutter build apk --release` fails when signing configuration is missing.
- A valid release build is signed with the expected certificate.
- Debug and release certificate fingerprints are different.

---

## 7. Tests, Linting, and CI Quality Gates Are Incomplete

**Severity:** Medium

### Evidence

- Wallet `flutter analyze` passes.
- The wallet has no `test` directory.
- Client `flutter analyze` passes.
- The client test suite passes 23 tests.
- Backend build passes.
- Backend unit tests pass 2 suites and 5 tests.
- Backend lint reports 140 errors and 17 warnings.
- Deployment CI builds the backend but does not run tests or lint.

### Recommended Fix

#### Backend

1. Add `jest` to the appropriate TypeScript test configuration:

   ```json
   {
     "compilerOptions": {
       "types": ["node", "jest"]
     }
   }
   ```

2. Prefer a separate `tsconfig.spec.json` so production compiler settings remain
   focused.
3. Configure `ts-jest` to use the test configuration.
4. Exclude generated Prisma code and local SDK scratch scripts from lint.
5. Resolve the remaining application-code lint issues.
6. Add service tests for:
   - wallet creation and validation
   - refresh-token rotation
   - OAuth code exchange and replay prevention
   - PKCE
   - scope filtering
   - consent expiration and revocation
   - KYC state transitions

#### Flutter Client

1. Replace polling based on real wall-clock delays in widget tests.
2. Drive asynchronous state with `tester.pump()` and bounded durations.
3. Ensure fake streams are closed in `addTearDown`.
4. Add lifecycle/disposal support where the production callback listener owns
   resources.
5. Make the widget test fail with a short timeout instead of hanging.

#### Wallet

Add tests for:

- auth notifier create/validate branches
- token refresh and forced logout
- biometric lock lifecycle
- permission callback construction
- KYC validation and phone formatting
- developer app creation and secret display
- route guards and deep-link restoration

#### CI

Require these checks before deployment:

```text
backend build
backend lint
backend unit tests
backend e2e tests
wallet analyze
wallet tests
client analyze
client tests
```

Deploy only after every required check succeeds.

### Verification

- All checks terminate successfully in a clean environment.
- A failing test prevents deployment.
- CI covers pull requests as well as pushes to `main`.
- Test output contains real domain tests rather than only generated starter
  tests.

---

## 8. Deployment Is Not Fully Reproducible

**Severity:** Medium

### Evidence

- GitHub Actions uses `appleboy/scp-action@master`.
- GitHub Actions uses `appleboy/ssh-action@master`.
- The repository uses pnpm, but the server runs `npm install --omit=dev`.
- The deploy artifact does not include the root pnpm lockfile.
- The backend has a Prisma generation `postinstall` script while Prisma CLI is a
  development dependency.

Mutable action tags and mixed package managers make it difficult to reproduce a
known deployment.

### Recommended Fix

1. Pin every third-party GitHub Action to a full commit SHA.
2. Declare the pnpm version in the root package:

   ```json
   {
     "packageManager": "pnpm@<exact-version>"
   }
   ```

3. Use the same Node and pnpm versions locally, in CI, and on the server.
4. Run:

   ```sh
   pnpm install --frozen-lockfile
   ```

5. Build and package the application in CI.
6. Prefer deploying a container image with a digest rather than installing
   dependencies on the production VM.
7. If retaining archive deployment, include the lockfile and use pnpm on the
   server.
8. Ensure Prisma generation occurs in a stage where the Prisma CLI is available.
9. Add a deployment health check and automatic rollback on failure.
10. Protect the deployment environment with GitHub environment approvals.

### Verification

- Re-running the same commit installs identical dependency versions.
- Actions cannot change without a repository commit.
- Production does not download unpinned packages during restart.
- A failed health check preserves or restores the previous working release.

---

## 9. Asset and Package Metadata Are Inconsistent

**Severity:** Low

### Evidence

- Wallet launcher icon configuration references
  `assets/images/ToroID.png`.
- The assets directory contains `ToroPass.png`, not `ToroID.png`.
- `packages/toropass_client/pubspec.yaml` links to the GitHub account
  `mav3rickx`.
- Project documentation and release URLs use `maverick0x`.
- The backend package still declares `UNLICENSED` while the project root uses
  Apache-2.0.

### Impact

Launcher-icon generation may fail, pub.dev links may send developers to the
wrong repository, and license metadata can be confusing.

### Recommended Fix

1. Update launcher icon paths to the intended existing image, or add the missing
   asset deliberately.
2. Run the launcher icon generator and inspect Android and iOS output.
3. Update `homepage`, `repository`, and `issue_tracker` to the canonical GitHub
   account.
4. Align package license metadata with the root Apache-2.0 license where
   appropriate.
5. Check all README, release, pub.dev, and documentation URLs.

### Verification

- Launcher icon generation succeeds.
- Every published metadata link resolves to the correct repository.
- License declarations are consistent across deliverables.

---

## Additional Hardening Recommendations

These were not ranked above but should be included in the remediation roadmap.

### Protect Stored Bearer Tokens

`OAuthToken.accessToken` and `UserSession.refreshToken` are stored in plaintext.
Hash opaque bearer tokens before storage so a database leak does not immediately
expose active credentials.

### Make Token Rotation Atomic

Create the replacement refresh session and revoke the previous session in a
single transaction. Consider token-family reuse detection so reuse of an old
rotated refresh token revokes the entire session family.

### Validate Authorization Requests With DTOs

Phase 1 added validated DTOs for OAuth authorization and token exchange.
Profile authorization-header parsing still needs a dedicated boundary. Validate:

- profile authorization header parsing

The implemented DTOs validate client IDs, redirect URIs, supported scopes, and
PKCE fields. Add an explicit grant type if the endpoint later supports more than
authorization-code exchange.

### Hash Authorization Codes

Store a digest of authorization codes rather than the bearer value itself. Hash
the presented code before lookup and keep the code lifetime short.

### Add Security-Focused Logging

Log identifiers and outcomes, but never:

- passwords
- BVNs
- authorization codes
- access tokens
- refresh tokens
- client secrets
- HMAC secrets

---

## Suggested Remediation Order

### Phase 1: Identity Boundary

1. Add PKCE.
2. Enforce OAuth scopes.
3. Enforce consent expiration and app status.
4. Invalidate tokens transactionally on revocation.

### Phase 2: Wallet-to-Issuer Security

1. Remove static secrets from the APK.
2. Redesign application attestation and request replay protection.
3. Apply endpoint-specific authentication and rate limits.

### Phase 3: Sensitive Data and Tokens

1. Replace raw BVN hashing with keyed HMAC.
2. Hash stored access and refresh tokens.
3. Implement atomic refresh-token rotation and reuse detection.

### Phase 4: Release Reliability

1. Make missing release signing configuration fatal.
2. Repair backend and client tests.
3. Add wallet tests.
4. Add lint, analyze, and test gates to CI.
5. Pin deployment dependencies and actions.

### Phase 5: Cleanup

1. Fix asset paths.
2. Correct package URLs.
3. Align license metadata.
4. Remove starter tests and stale comments.

## Audit Verification Results

| Check | Result |
| --- | --- |
| Wallet `flutter analyze` | Passed |
| Wallet tests | No test directory |
| Client `flutter analyze` | Passed |
| Client tests | Passed, 23 tests |
| Backend build | Passed |
| Backend unit tests | Passed, 2 suites and 6 tests |
| Backend e2e tests | Not rerun; requires a configured integration environment |
| Backend lint | Phase 1 OAuth files pass; existing repository-wide backlog remains |
| Tracked `.env` files | None found |
| Tracked keystores or `key.properties` | None found |

Phase 1 application changes were implemented after the initial audit and are
tracked in the remediation status above.
