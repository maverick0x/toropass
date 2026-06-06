# ToroPass Client OAuth Tasks

This file tracks the Flutter third-party package work needed to test the wallet-side OAuth flow end to end.

Primary references:

- [ToroPass Project Context](../../context/project.md)
- [Issuer API Reference](../../backend/toropass_issuer/API_REFERENCE.md)
- [Issuer Authentication](../../backend/toropass_issuer/AUTHENTICATION.md)
- [Wallet Integration Tasks](../../apps/toropass_wallet/tasks.md)

Status legend:

- `[ ]` Not started
- `[-]` In progress
- `[x]` Done

## Phase 1: Package Contract

- [ ] Define the public API for `ToroPassClient`
- [ ] Define a config object for `clientId`, `redirectUri`, scopes, and optional base URL override
- [ ] Define result types for success, cancel, denial, timeout, and transport error
- [ ] Decide whether the package exposes silent profile refresh helpers or only the initial identity flow

Definition of done:

- Third-party developers can understand exactly what they pass in and exactly what they get back.

## Phase 2: Wallet Launch and Deep Link Transport

- [ ] Define the wallet-launch URI format for `/permission`
- [ ] Include `client_id`, `redirect_uri`, and scopes in the outbound request
- [ ] Add request correlation via `state` or nonce so callback responses can be validated
- [ ] Add wallet availability detection and failure fallback when ToroPass Wallet is not installed

Definition of done:

- The package can launch ToroPass Wallet reliably with a valid permission request payload.

## Phase 3: Callback Capture and Result Mapping

- [ ] Listen for the app callback deep link
- [ ] Parse success callbacks with `code`
- [ ] Parse denial callbacks with `error=access_denied`
- [ ] Handle user-aborted or timed-out flows cleanly
- [ ] Validate callback correlation before accepting a response

Definition of done:

- The package can convert wallet callback deep links into safe, typed results.

## Phase 4: OAuth Token and Profile Flow

- [ ] Implement `POST /api/v1/oauth/token`
- [ ] Implement `GET /api/v1/oauth/profile`
- [ ] Keep OAuth app access tokens separate from first-party wallet tokens
- [ ] Decide whether OAuth app tokens live only in memory or can optionally be persisted by host apps
- [ ] Handle expired OAuth tokens and revoked consent responses consistently

Definition of done:

- The package can exchange a wallet-issued code for an app token and fetch the authorized profile.

Important note:

- `client_secret` is optional at the backend controller level, but shipping a secret inside a mobile client should be avoided by default.

## Phase 5: Package UX Helpers

- [ ] Expose a simple `verifyIdentity()` method
- [ ] Add an optional `ToroPassButton` widget for common integration
- [ ] Surface loading and error states that host apps can style
- [ ] Provide clear messaging for wallet-missing, denied, expired, and revoked states

Definition of done:

- A third-party Flutter app can integrate ToroPass with minimal custom glue code.

## Phase 6: Example App and Joint Testing

- [ ] Create a package example app that registers a callback URI and launches ToroPass Wallet
- [ ] Test logged-in wallet approval flow
- [ ] Test logged-out wallet flow that redirects through sign-in before consent
- [ ] Test `Deny` and top-right `X` callback behavior
- [ ] Test reused or expired authorization code behavior
- [ ] Test OAuth profile fetch after approval
- [ ] Test revoked consent causing OAuth profile/token failure

Definition of done:

- The package and wallet can be tested together against the live issuer contract.

## Phase 10 Joint Test Matrix

- [ ] Wallet already logged in -> approve -> callback returns `code` -> package exchanges token -> package fetches profile
- [ ] Wallet not logged in -> sign in -> approve -> callback returns `code` -> package exchanges token -> package fetches profile
- [ ] User taps `Deny` -> callback returns `access_denied` -> app receives denied result
- [ ] User taps `X` or back -> callback returns `access_denied` -> app receives denied result
- [ ] Authorization code is reused or expired -> token exchange fails with expected package error
- [ ] Consent is revoked from ToroPass Wallet -> existing OAuth profile request fails and client token is treated as invalid
- [ ] Debug and release environments point to the correct issuer base URLs

Current blocker:

- The package itself is still the default Flutter template, so phase 10 cannot be completed until phases 1 through 6 are implemented.
