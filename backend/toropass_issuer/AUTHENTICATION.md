# ToroPass Issuer Authentication

ToroPass Issuer uses layered authentication. Not every endpoint uses every layer.

## Auth Mechanisms

### 1. Shared API Key

Guard: `ApiGuard`

Required header:

```http
x-api-key: <APP_API_KEY>
```

Behavior:

- Rejects requests when `APP_API_KEY` is missing from server config.
- Rejects requests when the provided header does not match exactly.

Used by:

- All wallet routes
- KYC routes
- App registration and consent-management routes

### 2. First-Party Wallet JWT

Guard: `AuthGuard`

Required header:

```http
Authorization: Bearer <wallet_access_token>
```

Behavior:

- Verifies the JWT with `JWT_SECRET`
- Loads the user from Postgres using `payload.sub`
- Rejects missing, expired, malformed, or stale tokens

Issued by:

- `POST /api/v1/wallets/create`
- `POST /api/v1/wallets/validate`
- `POST /api/v1/wallets/refresh`

Used by:

- `GET /api/v1/wallets`
- `POST /api/v1/wallets/change-password`
- `POST /api/v1/kyc/verify`
- `POST /api/v1/oauth/apps/register`
- `GET /api/v1/oauth/apps`
- `DELETE /api/v1/oauth/apps/:appId`
- `POST /api/v1/oauth/authorize`
- `GET /api/v1/conscents`
- `DELETE /api/v1/conscents/:appId`

### 3. HMAC Request Signing

Guard: `HmacAuthGuard`

Required headers:

```http
x-device-id: <stable-device-id>
x-timestamp: <unix-seconds>
x-signature: <hex-hmac>
```

Signature algorithm:

- Message format: `<timestamp>:<deviceId>`
- Algorithm: `HMAC-SHA256`
- Secret: `APP_SECRET`
- Output encoding: lowercase hex

Validation rules:

- Request age must be within 120 seconds of server time
- Missing headers are rejected
- Invalid or malformed signatures are rejected
- Guard stores `deviceId` on the request for downstream use

Used by:

- `GET /api/v1/wallets`
- `GET /api/v1/wallets/tns`
- `POST /api/v1/wallets/create`
- `POST /api/v1/wallets/validate`
- `POST /api/v1/wallets/change-password`
- `POST /api/v1/wallets/refresh`
- `POST /api/v1/kyc/verify`
- `POST /api/v1/oauth/apps/register`
- `GET /api/v1/oauth/apps`
- `DELETE /api/v1/oauth/apps/:appId`
- `POST /api/v1/oauth/authorize`
- `GET /api/v1/conscents`
- `DELETE /api/v1/conscents/:appId`

## HMAC Example

Pseudocode:

```text
timestamp = current unix timestamp in seconds
message = timestamp + ":" + deviceId
signature = HMAC_SHA256_HEX(APP_SECRET, message)
```

Example request headers:

```http
x-api-key: your-api-key
Authorization: Bearer eyJ...
x-device-id: emulator-5554
x-timestamp: 1780732800
x-signature: 4f0c1f...
```

## Route Protection Matrix

| Route group | API key | JWT | HMAC |
| --- | --- | --- | --- |
| `GET /api/v1/wallets/tns` | Yes | No | Yes |
| `POST /api/v1/wallets/create` | Yes | No | Yes |
| `POST /api/v1/wallets/validate` | Yes | No | Yes |
| `GET /api/v1/wallets` | Yes | Yes | Yes |
| `POST /api/v1/wallets/change-password` | Yes | Yes | Yes |
| `POST /api/v1/wallets/refresh` | Yes | No | Yes |
| `POST /api/v1/kyc/verify` | Yes | Yes | Yes |
| `POST /api/v1/oauth/apps/register` | Yes | Yes | Yes |
| `GET /api/v1/oauth/apps` | Yes | Yes | Yes |
| `DELETE /api/v1/oauth/apps/:appId` | Yes | Yes | Yes |
| `POST /api/v1/oauth/authorize` | Yes | Yes | Yes |
| `POST /api/v1/oauth/token` | No | No | No |
| `GET /api/v1/oauth/profile` | No | No | OAuth token only |
| `GET /api/v1/conscents` | Yes | Yes | Yes |
| `DELETE /api/v1/conscents/:appId` | Yes | Yes | Yes |
| `GET /` | No | No | No |

Third-party package exception:

- The third-party client package endpoints are `POST /api/v1/oauth/token` and `GET /api/v1/oauth/profile`.
- Those two routes remain outside the HMAC layer so external clients can exchange authorization codes and fetch profiles with OAuth tokens alone.

## Integration Advice For The Wallet App

- Always send `x-api-key` to first-party backend routes.
- Centralize HMAC signing in one client utility so signed routes stay consistent.
- Treat wallet JWTs and OAuth app access tokens as separate token types.
- Include HMAC signing on refresh requests the same way you do for other signed first-party routes.
