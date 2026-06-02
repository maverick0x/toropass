# Wallets API (/v1/wallets)

Base path: /v1/wallets
Controller-level guard: ApiGuard (X-API-KEY)

1) GET /v1/wallets/tns?username={username}
- Description: Check TNS username availability.
- Guards: ApiGuard
- Query param: username (required)

Success (200)
{
  "status": "success",
  "data": {
    "username": "alice",
    "isAvailable": true,
    "message": "Username is available!"
  }
}

Errors
- 400 Bad Request: missing username.

Curl
curl -X GET "https://localhost:3000/api/v1/wallets/tns?username=alice" -H "x-api-key: your_super_secret_flutter_api_key_here"

2) POST /v1/wallets/create
- Description: Provision a new Toronet wallet and claim a TNS name.
- Guards: ApiGuard
- Body: { "username": "alice", "password": "S3cret!" }

Success (200)
{
  "status": "success",
  "message": "Toronet wallet and TNS name claimed successfully.",
  "data": {
    "username": "alice",
    "walletAddress": "tns:alice",
    "onChainTx": "tx_0xabc...",
    "createdAt": "2026-05-29T22:30:00Z"
  }
}

Errors
- 409 Conflict: username already taken.
- 400 Bad Request: invalid payload.

3) POST /v1/wallets/validate
- Description: Validate existing wallet credentials.
- Guards: ApiGuard
- Body: { "username": "alice", "password": "S3cret!" }

Success (200)
{ "status":"success","message":"Wallet validated successfully.","data":{"username":"alice","valid":true,"walletAddress":"tns:alice"} }

Errors
- 401 Unauthorized: invalid credentials.

4) POST /v1/wallets/change-password
- Description: Change wallet password for authenticated user.
- Guards: ApiGuard, AuthGuard (method-level)
- Headers: Authorization: Bearer <token>
- Body: { "oldPassword": "old","newPassword": "new1234" }

Success (200)
{ "status":"success","message":"Password changed successfully." }

Errors
- 400 Bad Request: validation error (new password too short).
- 401 Unauthorized: invalid token or credentials.

5) POST /v1/wallets/refresh
- Description: Refresh session tokens using a refresh token.
- Guards: ApiGuard
- Body: { "refreshToken": "refresh_abc" }

Success (200)
{
  "status": "success",
  "message": "Session refreshed successfully.",
  "data": {
    "accessToken": "eyJhb...",
    "refreshToken": "refresh_new",
    "expiresIn": 3600
  }
}

Errors
- 400 Bad Request: missing refreshToken.
- 401 Unauthorized: invalid/expired refresh token.

Curl example (refresh):
curl -X POST "https://{HOST}/v1/wallets/refresh" -H "Content-Type: application/json" -H "X-API-KEY: <api-key>" -d '{"refreshToken":"refresh_abc"}'
