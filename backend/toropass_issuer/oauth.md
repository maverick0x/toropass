# OAuth API (/v1/oauth)

Base path: /v1/oauth
Guards: ApiGuard (X-API-KEY) and AuthGuard (Authorization: Bearer <token>) on protected endpoints.

1) POST /v1/oauth/apps/register
- Description: Register a new OAuth application for the authenticated user.
- Guards: ApiGuard, AuthGuard
- Body (JSON):
  {
    "name": "My App",
    "redirectUri": "https://app.example.com/callback"
  }

Success (200)
{
  "status": "success",
  "message": "Application credentials generated successfully. Save the client secret safely!",
  "data": {
    "clientId": "cli_abc123",
    "clientSecret": "sec_xyz789",
    "name": "My App",
    "redirectUri": "https://app.example.com/callback",
    "ownerId": "user_123"
  }
}

Errors
- 400 Bad Request: validation failure (missing name/redirectUri).
- 401 Unauthorized: missing/invalid token.

Curl
curl -X POST "https://{HOST}/v1/oauth/apps/register" \
  -H "Content-Type: application/json" \
  -H "X-API-KEY: <api-key>" \
  -H "Authorization: Bearer <token>" \
  -d '{"name":"My App","redirectUri":"https://app.example.com/callback"}'


2) GET /v1/oauth/apps
- Description: List apps registered by the authenticated user.
- Guards: ApiGuard, AuthGuard

Success (200)
{
  "status": "success",
  "data": [
    { "clientId":"cli_abc123","name":"My App","redirectUri":"https://..." }
  ]
}

3) DELETE /v1/oauth/apps/:appId
- Description: Delete a registered app by id for the authenticated user.
- Guards: ApiGuard, AuthGuard
- Path param: appId

Success (200)
{ "status":"success", "message":"Application deleted." }

4) POST /v1/oauth/authorize
- Description: Generate an authorization code for the authenticated user for a client.
- Guards: ApiGuard, AuthGuard
- Body: { "client_id": "cli_...", "redirect_uri":"https://...","scopes": ["profile","email"] }

Success (200)
{ "status":"success", "data": { "code": "auth_code_123" } }

5) POST /v1/oauth/token
- Description: Exchange an authorization code for tokens or user profile.
- Guards: none (public endpoint used by clients)
- Body: { "client_id": "cli_...", "code": "auth_code_123", "redirect_uri":"https://...", "client_secret":"optional" }

Success (200)
{
  "status":"success",
  "data": {
    "accessToken": "eyJhb...",
    "refreshToken": "refresh_abc",
    "expiresIn": 3600,
    "tokenType": "Bearer"
  }
}

Errors
- 400 Bad Request: invalid grant, mismatched redirect URI.
- 401 Unauthorized: invalid client_secret when provided.

6) GET /v1/oauth/profile
- Description: Verify access token and return user profile.
- Headers: Authorization: Bearer <access_token>
- Returns user profile or 401 if token invalid/missing.

Success (200)
{ "status":"success", "data": { "id":"user_123","email":"alice@example.com","name":"Alice" } }

Curl example (token exchange):
curl -X POST "https://{HOST}/v1/oauth/token" -H "Content-Type: application/json" -d '{"client_id":"cli_abc","code":"auth_code","redirect_uri":"https://app.example.com/cb","client_secret":"sec"}'
