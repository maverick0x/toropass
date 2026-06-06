# ToroPass Wallet Backend Contract

This document maps the wallet app to the current issuer backend contract.

Primary source docs:

- [Issuer README](../../backend/toropass_issuer/README.md)
- [Issuer API Reference](../../backend/toropass_issuer/API_REFERENCE.md)
- [Issuer Authentication](../../backend/toropass_issuer/AUTHENTICATION.md)
- [Issuer Communication Examples](../../backend/comms.txt)

## Route Matrix

### First-Party Wallet Routes

| Route | Purpose | Auth | Wallet app status |
| --- | --- | --- | --- |
| `GET /api/v1/wallets/tns?username=` | Check TNS availability | `x-api-key` + HMAC | Implemented in auth repo |
| `POST /api/v1/wallets/create` | Create new wallet | `x-api-key` + HMAC | Implemented in auth repo |
| `POST /api/v1/wallets/validate` | Validate existing wallet | `x-api-key` + HMAC | Implemented in auth repo |
| `GET /api/v1/wallets` | Fetch wallet profile | `x-api-key` + JWT + HMAC | Repository exists, request currently misconfigured |
| `POST /api/v1/wallets/change-password` | Change wallet password | `x-api-key` + JWT + HMAC | Implemented in user repo |
| `POST /api/v1/wallets/refresh` | Refresh wallet session | `x-api-key` + HMAC | Implemented in token repo / auth interceptor |
| `POST /api/v1/kyc/verify` | Submit KYC | `x-api-key` + JWT + HMAC | Implemented |
| `GET /api/v1/conscents` | List connected apps | `x-api-key` + JWT + HMAC | Implemented |
| `DELETE /api/v1/conscents/:appId` | Revoke consent | `x-api-key` + JWT + HMAC | Implemented |
| `POST /api/v1/oauth/apps/register` | Register developer app | `x-api-key` + JWT + HMAC | Implemented |
| `GET /api/v1/oauth/apps` | List developer apps | `x-api-key` + JWT + HMAC | Implemented |
| `DELETE /api/v1/oauth/apps/:appId` | Delete developer app | `x-api-key` + JWT + HMAC | Implemented |
| `POST /api/v1/oauth/authorize` | Approve app consent and issue code | `x-api-key` + JWT + HMAC | Not implemented |

### Third-Party Client Package Routes

These are not wallet-app routes and should stay logically separate in the Flutter wallet:

| Route | Purpose | Auth |
| --- | --- | --- |
| `POST /api/v1/oauth/token` | Exchange code for OAuth access token | Public at route level |
| `GET /api/v1/oauth/profile` | Fetch profile using OAuth access token | OAuth access token |

## Current App Foundation

### Already Present

- `API_BASE_URL` is already loaded from `.env`
- `APP_API_KEY` is already attached by the auth interceptor
- device ID is already sourced and injected at app startup
- HMAC signing is already implemented in `hmacProvider`
- `Authorization: Bearer <wallet access token>` is already attached when `useToken: true`
- refresh flow already attempts signed refresh requests on `401`
- wallet and auth repositories already exist for:
  - TNS lookup
  - wallet create
  - wallet validate
  - wallet refresh
  - wallet change password

### Gaps Found During Contract Review

- `getWallet()` currently calls a JWT-protected route with `useToken: false`
- the refresh-loop guard in `QueuedAuthInterceptor` checks for `'/refresh-token'`, but the actual backend path is `'/wallets/refresh'`
- endpoint constants do not yet cover:
  - KYC
  - consent routes
  - OAuth app-management routes
  - wallet-side authorize route
- app-side models are still missing for:
  - KYC requests
  - consent list / revoke responses
  - developer app registration / listing
  - wallet-side OAuth authorize flow
- first-party wallet JWT and later OAuth app tokens are conceptually separate, but the app has not yet implemented that separation in feature code because OAuth app flows are not wired yet

## Auth Rules To Preserve

- First-party wallet routes must send HMAC unless backend docs explicitly say otherwise
- `x-api-key` is required for all first-party issuer routes
- JWT should only be attached for routes that require authenticated wallet context
- OAuth app access tokens must not be mixed into the first-party wallet token store

## Immediate Follow-Up Work

1. Fix the `GET /wallets` repository call to use wallet JWT auth.
2. Fix refresh-path handling in the auth interceptor.
3. Add endpoint constants and request/response models for KYC, consent, and developer routes.
4. Start wiring those routes feature-by-feature.
