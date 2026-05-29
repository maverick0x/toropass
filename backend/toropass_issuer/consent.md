# Consent API (/v1/conscents/:userId)

Base path: /v1/conscents/:userId
Controller-level guard: ApiGuard (X-API-KEY)

1) GET /v1/conscents/:userId
- Description: Retrieve all OAuth consents granted by a user.
- Guards: ApiGuard
- Path params:
  - userId: string

Success (200)
{
  "status":"success",
  "data": [
    {
      "appId": "cli_abc123",
      "appName": "My App",
      "scopes": ["profile","email"],
      "grantedAt": "2026-05-01T12:00:00Z"
    }
  ]
}

Errors
- 400 Bad Request: malformed userId.
- 404 Not Found: user not found or no consents.

Curl
curl -X GET "https://{HOST}/v1/conscents/{userId}" -H "X-API-KEY: <api-key>"

2) DELETE /v1/conscents/:userId/:appId
- Description: Revoke consent for a client application for the given user.
- Guards: ApiGuard
- Path params:
  - userId: string
  - appId: string

Success (200)
{ "status": "success", "message": "Consent revoked successfully." }

Errors
- 404 Not Found: consent entry not found.
- 403 Forbidden: operation not allowed (if guard enforces policies).
