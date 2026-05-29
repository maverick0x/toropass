# ToroPass Issuer — API Reference

Base URL: https://{HOST}
Versioning: Controllers with version: '1' use /v1/ prefix. HealthController is VERSION_NEUTRAL and available at root (/).

Common response format:

{
  "status": "success" | "error",
  "message"?: string,
  "data"?: any
}

Authentication & Guards
- ApiGuard: Required on many endpoints. (Check src/core/guards/api.guard for exact header name; commonly X-API-KEY or x-api-key.)
- AuthGuard: Requires Authorization: Bearer <token> header.

---

## Health
GET /
- Purpose: Health check for server, database and Toronet/blockchain dependency.
- Auth: none
- Success (200):
```
{
  "status": "success",
  "message": "ToroPass Issuer Server is live 🚀",
  "timestamp": "2026-05-29T...",
  "dependencies": { "database": "UP", "toronet": "UP" }
}
```
- Failure (503 when dependency down): same shape with status: "error" and ServiceUnavailable response.

Curl example:

curl -X GET "https://{HOST}/" -H "Accept: application/json"

---

## OAuth (/v1/oauth)
Controller: OAuthController

1) POST /v1/oauth/apps/register
- Guards: ApiGuard, AuthGuard
- Body (JSON):
  - name: string (required)
  - redirectUri: string (required, valid URL)
- Response: status, message and data containing client credentials.

Curl example:
```
curl -X POST "https://{HOST}/v1/oauth/apps/register" \
  -H "Content-Type: application/json" \
  -H "X-API-KEY: <api-key>" \
  -H "Authorization: Bearer <token>" \
  -d '{"name":"My App","redirectUri":"https://app.example.com/cb"}'
```

2) GET /v1/oauth/apps
- Guards: ApiGuard, AuthGuard
- Returns array of registered apps.

3) DELETE /v1/oauth/apps/:appId
- Guards: ApiGuard, AuthGuard
- Path param: appId

4) POST /v1/oauth/authorize
- Guards: ApiGuard, AuthGuard
- Body (form/json): client_id, redirect_uri, scopes (string[])
- Response: { status: 'success', data: { code: '<authorization_code>' } }

5) POST /v1/oauth/token
- Guards: none (public)
- Body: client_id, code, redirect_uri, client_secret? (optional)
- Response: token exchange result (access/refresh tokens or user profile per service)

6) GET /v1/oauth/profile
- Headers: Authorization: Bearer <access_token>
- Response: verifyAccessToken result (user profile/token validation)

Curl example (token exchange):
```
curl -X POST "https://{HOST}/v1/oauth/token" \
  -H "Content-Type: application/json" \
  -d '{"client_id":"<id>","code":"<code>","redirect_uri":"https://app.example.com/cb","client_secret":"<secret>"}'
```

---

## Consents (/v1/conscents/:userId)
Controller: ConsentController
Controller-level: ApiGuard

1) GET /v1/conscents/:userId
- Guards: ApiGuard
- Path param: userId
- Response: list of consents for given user.

2) DELETE /v1/conscents/:userId/:appId
- Guards: ApiGuard
- Path params: userId, appId
- Response: { status: 'success', message: '<result.message>' }

Curl example:
```
curl -X GET "https://{HOST}/v1/conscents/abcd-1234" -H "X-API-KEY: <api-key>"
```

---

## KYC (/v1/kyc)
Controller: KycController
Controller-level: ApiGuard, AuthGuard

POST /v1/kyc/verify
- Body (JSON) VerifyKycDto:
  - firstName: string
  - middleName?: string
  - lastName: string
  - bvn: string
  - currency: string
  - phoneNumber: string
  - dob: string (YYYY-MM-DD)
  - address: string (Toronet wallet address)
- Response: verification result in data.

Curl example:
```
curl -X POST "https://{HOST}/v1/kyc/verify" \
  -H "Content-Type: application/json" \
  -H "X-API-KEY: <api-key>" \
  -H "Authorization: Bearer <token>" \
  -d '{"firstName":"Alice","lastName":"Doe","bvn":"12345678901","currency":"NGN","phoneNumber":"+2348012345678","dob":"1990-01-01","address":"tns:alice"}'
```

---

## Wallets (/v1/wallets)
Controller: WalletController
Controller-level: ApiGuard

1) GET /v1/wallets/tns?username={username}
- Guards: ApiGuard
- Query param: username (required)
- Response:
```
{
  "status":"success",
  "data":{ "username":"normalized", "isAvailable": true|false, "message":"..." }
}
```

Curl example:
```
curl -X GET "https://{HOST}/v1/wallets/tns?username=alice" -H "X-API-KEY: <api-key>"
```

2) POST /v1/wallets/create
- Body: CreateWalletDto { username, password }
- Response: provisioning result; includes username and wallet details.

3) POST /v1/wallets/validate
- Body: ValidateWalletDto { username, password }
- Response: validation result

4) POST /v1/wallets/change-password
- Guards: ApiGuard, AuthGuard (method-level)
- Headers: Authorization: Bearer <token>
- Body: ChangePasswordDto { oldPassword, newPassword }
- Response: { status: 'success', message: '<result.message>' }

5) POST /v1/wallets/refresh
- Body: RefreshDto { refreshToken }
- Response: { status: 'success', message: 'Session refreshed successfully.', data: { /* tokens */ } }

Curl example (create):
```
curl -X POST "https://{HOST}/v1/wallets/create" \
  -H "Content-Type: application/json" \
  -H "X-API-KEY: <api-key>" \
  -d '{"username":"alice","password":"S3cret!"}'
```

---

Notes & next steps
- Confirm exact ApiGuard header name and any required header value format by inspecting src/core/guards/api.guard.
- Confirm global versioning strategy (URI prefix /v1 or header-based) by checking bootstrap/main app module.

This file was generated from controllers in src/presentation. For machine-readable API schemas, consider generating an OpenAPI spec from code (Swagger) or adding detailed DTO examples.
