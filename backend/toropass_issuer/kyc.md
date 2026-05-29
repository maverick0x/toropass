# KYC API (/v1/kyc)

Base path: /v1/kyc
Guards: ApiGuard, AuthGuard (controller-level)

POST /v1/kyc/verify
- Description: Submit user identity information for KYC verification.
- Guards: ApiGuard, AuthGuard
- Body (VerifyKycDto):
  {
    "firstName": "Alice",
    "middleName": "M",
    "lastName": "Doe",
    "bvn": "12345678901",
    "currency": "NGN",
    "phoneNumber": "+2348012345678",
    "dob": "1990-01-01",
    "address": "tns:alice"
  }

Success (200)
{
  "status": "success",
  "data": {
    "verificationId": "kyc_123",
    "status": "PENDING" | "VERIFIED" | "FAILED",
    "checkedAt": "2026-05-29T22:00:00Z",
    "notes": "Optional notes from verification provider"
  }
}

Common error responses
- 400 Bad Request: missing fields or invalid formats (e.g., dob).
- 401 Unauthorized: missing/invalid Authorization header.
- 422 Unprocessable Entity: provider-specific rejection or invalid BVN.

Curl example
curl -X POST "https://{HOST}/v1/kyc/verify" \
  -H "Content-Type: application/json" \
  -H "X-API-KEY: <api-key>" \
  -H "Authorization: Bearer <token>" \
  -d '{"firstName":"Alice","lastName":"Doe","bvn":"12345678901","currency":"NGN","phoneNumber":"+2348012345678","dob":"1990-01-01","address":"tns:alice"}'
