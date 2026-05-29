# Health API

GET /

Description
- Lightweight health check for the ToroPass Issuer service.
- Verifies database connectivity and Toronet/blockchain dependency.

Authentication
- None (VERSION_NEUTRAL root endpoint).

Success Response (200)
{
  "status": "success",
  "message": "ToroPass Issuer Server is live 🚀",
  "timestamp": "2026-05-29T22:51:59.340Z",
  "dependencies": {
    "database": "UP",
    "toronet": "UP"
  }
}

Failure Response (503)
- If any critical dependency is DOWN the endpoint returns a 503 Service Unavailable with status: "error".

Example (503):
HTTP/1.1 503 Service Unavailable
{
  "status": "error",
  "message": "ToroPass Issuer Server is experiencing degraded performance.",
  "timestamp": "2026-05-29T22:51:59.340Z",
  "dependencies": { "database": "UP", "toronet": "DOWN" }
}

Curl

curl -X GET "https://{HOST}/" -H "Accept: application/json"
