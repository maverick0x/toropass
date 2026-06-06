# ToroPass Wallet Integration Tasks

This file tracks the wallet-app integration work against the issuer backend documentation.

Primary backend references:

- [Issuer README](../../backend/toropass_issuer/README.md)
- [Issuer API Reference](../../backend/toropass_issuer/API_REFERENCE.md)
- [Issuer Authentication](../../backend/toropass_issuer/AUTHENTICATION.md)
- [Issuer Communication Examples](../../backend/comms.txt)
- [Wallet Backend Contract](./backend_contract.md)

Status legend:

- `[ ]` Not started
- `[-]` In progress
- `[x]` Done

## Phase 1: Contract Mapping

- [x] Map all wallet-app backend routes from the issuer API reference
- [x] Classify each route by auth requirements
- [x] Confirm request/response field parity between backend and Flutter models at a high level
- [x] Identify all app-side models needed for wallet, KYC, consent, and developer flows
- [x] Document which backend routes are first-party only versus third-party package only

Definition of done:

- Every backend route needed by `toropass_wallet` is listed with method, path, auth mode, request shape, and response shape.

Current result:

- See [backend_contract.md](./backend_contract.md)

## Phase 2: Networking Foundation

- [x] Create a single backend configuration source for the wallet app
- [x] Add base URL handling for local/dev/prod environments
- [x] Add backend API key handling
- [x] Add a stable device ID source for signed requests
- [x] Implement a reusable HMAC signing service
- [x] Ensure the API client can attach `x-api-key`
- [x] Ensure the API client can attach `Authorization`
- [x] Ensure the API client can attach `x-device-id`
- [x] Ensure the API client can attach `x-timestamp`
- [x] Ensure the API client can attach `x-signature`
- [-] Separate first-party wallet JWT handling from any later OAuth app-token handling

Definition of done:

- Any documented first-party request can be made with the correct auth headers from one shared networking stack.

Current gaps:

- [x] Fix `getWallet()` to send wallet JWT auth
- [x] Fix refresh loop detection to match `/wallets/refresh`
- [x] Add endpoint constants for KYC, consent, OAuth app management, and authorize routes
- [x] Decide whether environment switching needs explicit app-side profiles beyond `API_BASE_URL`

Resolved decision:

- Debug builds use `http://localhost:3000/api/v1/`
- Release builds use `https://api.toropass.app/api/v1/`

## Phase 3: Wallet Auth and Session Flow

- [x] Wire `GET /api/v1/wallets/tns`
- [x] Wire `POST /api/v1/wallets/create`
- [x] Wire `POST /api/v1/wallets/validate`
- [x] Wire `POST /api/v1/wallets/refresh`
- [x] Wire `GET /api/v1/wallets`
- [x] Store wallet access token
- [x] Store wallet refresh token
- [x] Store current user id
- [x] Store current wallet profile
- [x] Store active wallet network
- [x] Handle app startup session restore
- [x] Handle token refresh on expiry
- [x] Handle forced logout when refresh fails

Definition of done:

- New and existing users can sign in, restore session, refresh session, and fetch their wallet profile end-to-end.

Current note:

- Profile data is now fetched on home bootstrap and drives the identity card / verification state, but downstream features like KYC and consent still need to consume it.

## Phase 4: Auth UI Completion

- [x] Align sign-in UI states with backend request lifecycle
- [x] Show backend validation errors for create wallet
- [x] Show backend validation errors for validate wallet
- [x] Handle loading, success, and failure states for profile bootstrap
- [x] Handle network/auth failures in a user-friendly way

Definition of done:

- The sign-in flow behaves correctly against the live backend and surfaces actionable feedback.

## Phase 5: KYC Integration

- [x] Add request model for `POST /api/v1/kyc/verify`
- [x] Build app-side KYC input flow
- [x] Send KYC payload using documented auth requirements
- [x] Update state using backend KYC response
- [x] Reflect `kycVerified` and `kycAnchorHash` in the app
- [x] Handle KYC failure messaging cleanly

Definition of done:

- A signed-in user can submit KYC data and see the verified state update correctly.

## Phase 6: Consent Management

- [x] Wire `GET /api/v1/conscents`
- [x] Wire `DELETE /api/v1/conscents/:appId`
- [x] Build consent list models from the documented response
- [x] Build the Connected Apps screen using the live consent contract
- [x] Handle consent revocation success and failure states
- [x] Ensure app logic relies on authenticated user context from JWT

Definition of done:

- The Connected Apps experience loads real consent data and supports revocation.

## Phase 7: Developer Dashboard

- [ ] Wire `POST /api/v1/oauth/apps/register`
- [ ] Wire `GET /api/v1/oauth/apps`
- [ ] Wire `DELETE /api/v1/oauth/apps/:appId`
- [ ] Build models for developer app registration/listing
- [ ] Build the hidden developer dashboard flow around the live backend
- [ ] Show client secret once and handle it carefully in UI

Definition of done:

- A developer using the hidden dashboard can register, view, and delete OAuth apps from the wallet.

## Phase 8: Wallet-Side OAuth Consent Flow

- [ ] Wire `POST /api/v1/oauth/authorize`
- [ ] Model scopes and redirect URI handling in the wallet
- [ ] Build consent approval UI for third-party apps
- [ ] Keep wallet-auth flows separate from third-party OAuth token/profile flows

Definition of done:

- The wallet can approve app access and issue authorization codes through the documented backend contract.

## Phase 9: Error Handling and Security Hardening

- [ ] Normalize backend errors into app-level domain errors
- [ ] Handle invalid wallet password responses
- [ ] Handle expired access token flows
- [ ] Handle revoked refresh token flows
- [ ] Handle invalid HMAC responses
- [ ] Handle revoked consent states
- [ ] Review storage boundaries for tokens and other sensitive values

Definition of done:

- Expected auth, session, and security failures are handled gracefully and consistently.

## Phase 10: End-to-End Verification

- [ ] Test new-user path end-to-end
- [ ] Test existing-user path end-to-end
- [ ] Test refresh-token path end-to-end
- [ ] Test wallet profile bootstrap end-to-end
- [ ] Test KYC submission end-to-end
- [ ] Test consent list/revoke end-to-end
- [ ] Test developer app register/list/delete end-to-end
- [ ] Verify every protected route sends the documented headers

Definition of done:

- The wallet app and issuer backend work together across all documented first-party flows.

## Suggested Working Order

- [x] Phase 1: Contract Mapping
- [-] Phase 2: Networking Foundation
- [x] Phase 3: Wallet Auth and Session Flow
- [x] Phase 4: Auth UI Completion
- [x] Phase 5: KYC Integration
- [x] Phase 6: Consent Management
- [ ] Phase 7: Developer Dashboard
- [ ] Phase 8: Wallet-Side OAuth Consent Flow
- [ ] Phase 9: Error Handling and Security Hardening
- [ ] Phase 10: End-to-End Verification
