# ToroPass Issuer Backend

ToroPass Issuer is the trusted backend for the ToroPass identity system. It provisions and validates Toronet wallets, performs KYC anchoring, manages first-party wallet sessions, and exposes OAuth-style app and consent flows for the wider ToroPass ecosystem.

This document is the backend overview. Use the companion docs for integration details:

- [API_REFERENCE.md](./API_REFERENCE.md)
- [AUTHENTICATION.md](./AUTHENTICATION.md)

## What This Service Does

- Checks `.toro` username availability against Toronet.
- Creates new wallets and claims TNS names on behalf of the wallet app.
- Validates existing Toronet wallets and links them to local ToroPass users.
- Issues wallet access and refresh tokens for first-party app sessions.
- Performs KYC verification and stores verified status in Postgres after on-chain anchoring succeeds.
- Registers developer apps, stores consent, issues OAuth codes/tokens, and serves app-scoped user profiles.

## Runtime Shape

- Framework: NestJS
- Database: PostgreSQL via Prisma
- Blockchain integration: `torosdk`
- API base: `/api/v1`
- Health endpoint: `/`
- Rate limiting: 10 requests per 60 seconds per IP

## Main Domains

### Wallets

Implemented in:

- [wallet.controller.ts](./src/presentation/wallet.controller.ts)
- [wallet.service.ts](./src/core/application/wallet.service.ts)

Responsibilities:

- TNS availability lookup
- New wallet provisioning
- Existing wallet validation
- Wallet profile retrieval
- Password changes
- Refresh-token exchange

### KYC

Implemented in:

- [kyc.controller.ts](./src/presentation/kyc.controller.ts)
- [kyc.service.ts](./src/core/application/kyc.service.ts)

Responsibilities:

- Receives first-party KYC payloads
- Calls Toronet admin-backed KYC verification
- Marks local users as verified after successful blockchain anchoring

### OAuth and Consent

Implemented in:

- [oauth.controller.ts](./src/presentation/oauth.controller.ts)
- [conscent.controller.ts](./src/presentation/conscent.controller.ts)
- [oauth.service.ts](./src/core/application/oauth.service.ts)

Responsibilities:

- App registration for developers
- Authorization code issuance
- Token exchange for third-party apps
- Profile retrieval with app-scoped access tokens
- User consent listing and revocation for the authenticated wallet user

## Data Model Summary

Key Prisma models in [schema.prisma](./prisma/schema.prisma):

- `User`: ToroPass user record, password hash, KYC state, KYC anchor hash
- `Wallet`: active Toronet wallet linked to a user
- `UserSession`: refresh-token-backed first-party wallet sessions
- `OAuthApp`: registered third-party developer apps
- `OAuthConsent`: user-to-app consent grants and scopes
- `OAuthCode`: short-lived authorization codes
- `OAuthToken`: app-scoped access tokens for profile access

## Authentication Layers

Different endpoints use different combinations of these mechanisms:

- `x-api-key`: shared backend API key
- `Authorization: Bearer <jwt>`: first-party wallet access token
- HMAC headers: request signing with device identity

See [AUTHENTICATION.md](./AUTHENTICATION.md) for exact header requirements.

Current rule:

- All first-party wallet and internal issuer endpoints use HMAC signing.
- The only live endpoints that do not use HMAC are the third-party client package endpoints: `POST /api/v1/oauth/token` and `GET /api/v1/oauth/profile`.

## Environment Variables

The current code depends on these values:

- `DATABASE_URL`: Prisma PostgreSQL connection string
- `APP_API_KEY`: required by `ApiGuard`
- `APP_SECRET`: required by `HmacAuthGuard`
- `JWT_SECRET`: used for first-party wallet JWTs
- `BLOCKCHAIN_NETWORK`: Toronet SDK network, supported values are `mainnet` and `testnet`
- `MAINNET_ADMIN_ADDRESS`: Toronet admin wallet for KYC when `BLOCKCHAIN_NETWORK=mainnet`
- `MAINNET_ADMIN_PASSWORD`: Toronet admin wallet password for KYC when `BLOCKCHAIN_NETWORK=mainnet`
- `TESTNET_ADMIN_ADDRESS`: Toronet admin wallet for KYC when `BLOCKCHAIN_NETWORK=testnet`
- `TESTNET_ADMIN_PASSWORD`: Toronet admin wallet password for KYC when `BLOCKCHAIN_NETWORK=testnet`
- `PORT`: optional, defaults to `3000`

## Local Development

Install dependencies:

```bash
pnpm install
```

Start the backend in watch mode:

```bash
pnpm run start:dev
```

Generate Prisma client manually if needed:

```bash
pnpm prisma generate
```

Inspect the active blockchain configuration and run the SDK connectivity check:

```bash
pnpm run config
```

## Important Implementation Notes

- Toronet SDK network is selected from `BLOCKCHAIN_NETWORK` and defaults to `testnet` when unset.
- The backend reads admin credentials from the env pair that matches the active Toronet network.
- `Wallet.network` is persisted from the active Toronet adapter network during wallet creation and first-time wallet linking.
- `pnpm run config` initializes the SDK with the configured network and attempts a test wallet creation for quick connectivity verification.
- Newly created or newly linked users are stored with placeholder `bvnHash` and `dateOfBirth` until KYC completes.
- All wallet routes now require HMAC signing in addition to the shared API key.
- The consent route path is currently spelled `/conscents/...` in code. The docs preserve that exact live path to avoid integration mistakes.
- Consent routes now use the authenticated wallet user from the bearer token and no longer require `userId` in the path.
