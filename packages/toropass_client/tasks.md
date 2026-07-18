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

- [x] Define the public API for `ToroPassClient`
- [x] Define a config object for `clientId`, `redirectUri`, scopes, and optional base URL override
- [x] Define result types for success, cancel, denial, timeout, and transport error
- [x] Decide whether the package exposes silent profile refresh helpers or only the initial identity flow

Definition of done:

- Third-party developers can understand exactly what they pass in and exactly what they get back.

Current result:

- `ToroPassClient` exposes `verifyIdentity()`, `exchangeAuthorizationCode()`, and `fetchProfile()` as the core package API.
- `ToroPassClientConfig` carries `clientId`, `redirectUri`, scopes, issuer base URL, and callback timeout.
- OAuth profile refresh is exposed through `fetchProfile(accessToken:)`, but token persistence remains the host app's responsibility.

## Phase 2: Wallet Launch and Deep Link Transport

- [x] Define the wallet-launch URI format for `/permission`
- [x] Include `client_id`, `redirect_uri`, and scopes in the outbound request
- [x] Add request correlation via `state` or nonce so callback responses can be validated
- [x] Add wallet availability detection and failure fallback when ToroPass Wallet is not installed

Definition of done:

- The package can launch ToroPass Wallet reliably with a valid permission request payload.

Current result:

- Default wallet launch URI is `toropass:/permission`, with override support through `ToroPassClientConfig.walletLaunchUri`.
- `ToroPassClient.createAuthorizationRequest()` builds the launch URI with `client_id`, `redirect_uri`, comma-separated `scopes`, `state`, and optional `app_name`.
- `ToroPassClient.launchWallet()` checks app availability through `url_launcher` before opening the wallet and returns `null` when the wallet is unavailable.
- ToroPass Wallet now registers the matching `toropass` native scheme on Android and iOS.

## Phase 3: Callback Capture and Result Mapping

- [x] Listen for the app callback deep link
- [x] Parse success callbacks with `code`
- [x] Parse denial callbacks with `error=access_denied`
- [x] Handle user-aborted or timed-out flows cleanly
- [x] Validate callback correlation before accepting a response

Definition of done:

- The package can convert wallet callback deep links into safe, typed results.

Current result:

- `ToroPassClient.waitForCallback()` listens for callback URIs through `app_links`.
- `ToroPassClient.parseCallbackUri()` maps callback codes, denial errors, cancelled callbacks, timeouts, and state mismatches into typed results.
- Callback matching is scoped to the configured `redirectUri` scheme, host, and path.

## Phase 4: OAuth Token and Profile Flow

- [x] Implement `POST /api/v1/oauth/token`
- [x] Implement `GET /api/v1/oauth/profile`
- [x] Keep OAuth app access tokens separate from first-party wallet tokens
- [x] Decide whether OAuth app tokens live only in memory or can optionally be persisted by host apps
- [x] Handle expired OAuth tokens and revoked consent responses consistently

Definition of done:

- The package can exchange a wallet-issued code for an app token and fetch the authorized profile.

Important note:

- `client_secret` is optional at the backend controller level, but shipping a secret inside a mobile client should be avoided by default.

Current result:

- `ToroPassClient.exchangeAuthorizationCode()` requires the PKCE verifier,
  calls `/oauth/token`, and returns a `ToroPassOAuthSession`.
- `ToroPassClient.fetchProfile()` calls `/oauth/profile` with the app-scoped OAuth access token.
- The package does not persist OAuth app tokens; host apps own storage policy.
- Expired or revoked OAuth app tokens surface as `ToroPassTokenInvalidException`.
- S256 PKCE binds authorization codes to the app instance that initiated the
  wallet handoff.
- Profile fields are nullable and populated only when their scope was granted.

## Phase 5: Package UX Helpers

- [x] Expose a simple `verifyIdentity()` method
- [x] Add an optional `ToroPassButton` widget for common integration
- [x] Surface loading and error states that host apps can style
- [x] Provide clear messaging for wallet-missing, denied, expired, and revoked states

Definition of done:

- A third-party Flutter app can integrate ToroPass with minimal custom glue code.

Current result:

- `ToroPassClient.verifyIdentity()` now serves as the one-call launch, callback, token exchange, and profile fetch flow.
- `ToroPassButton` provides an optional package widget with built-in loading state and result callback handling.
- `ToroPassAuthResult.toStatusMessage()` maps package results into host-friendly titles, messages, and tones for app-specific UI.
- Host apps still control final presentation, storage, and layout while reusing the package's flow and state mapping.

## Phase 6: Example App and Joint Testing

- [x] Create a package example app that registers a callback URI and launches ToroPass Wallet
- [x] Test logged-in wallet approval flow
- [x] Test logged-out wallet flow that redirects through sign-in before consent
- [x] Test `Deny` and top-right `X` callback behavior
- [x] Test reused or expired authorization code behavior
- [x] Test OAuth profile fetch after approval
- [x] Test revoked consent causing OAuth profile/token failure

Definition of done:

- The package and wallet can be tested together against the live issuer contract.

Current result:

- Added a package `example/` app with the callback URI `toropassclient://oauth/callback`.
- The example supports both one-step `verifyIdentity()` and a manual code-capture flow for exchange and reuse testing.
- Added [`phase6-test.md`](./phase6-test.md) to walk through the remaining device-level scenarios.
- Completed the live simulator handoff from ToroPass Wallet back into the example app with real OAuth app credentials.
- Verified the callback, code exchange, and profile-fetch path after fixing native app-to-app visibility and callback handling.

## Phase 10 Joint Test Matrix

- [x] Wallet already logged in -> approve -> callback returns `code` -> package exchanges token -> package fetches profile
- [x] Wallet not logged in -> sign in -> approve -> callback returns `code` -> package exchanges token -> package fetches profile
- [x] User taps `Deny` -> callback returns `access_denied` -> app receives denied result
- [x] User taps `X` or back -> callback returns `access_denied` -> app receives denied result
- [x] Authorization code is reused or expired -> token exchange fails with expected package error
- [x] Consent is revoked from ToroPass Wallet -> existing OAuth profile request fails and client token is treated as invalid
- [x] Debug and release environments point to the correct issuer base URLs

Current blocker:

- None. ToroPass Client package integration and joint wallet testing are complete.
