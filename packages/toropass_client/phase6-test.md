# ToroPass Client Phase 6 Joint Test Guide

Use the package example app in [`example/`](./example) together with ToroPass Wallet to verify the real OAuth handoff.

## Example App Callback

```text
toropassclient://oauth/callback
```

## Preconditions

- Register a real OAuth app at the issuer with:
  - `client_id`
  - `redirect_uri = toropassclient://oauth/callback`
- Install both apps on the same simulator or device:
  - ToroPass Wallet
  - `toropass_client` example app
- Point the example app to the correct issuer base URL for the environment under test.

## Happy Path

1. Open the example app.
2. Enter the correct `client_id`.
3. Tap `Verify Identity`.
4. Approve in ToroPass Wallet.
5. Confirm the example app receives:
   - success status
   - access token
   - authorized profile

## Logged-Out Wallet Path

1. Ensure ToroPass Wallet has no active session.
2. Tap `Verify Identity` in the example app.
3. Sign in inside ToroPass Wallet when prompted.
4. Approve the consent request.
5. Confirm the callback still returns to the example app successfully.

## Deny And Cancel

1. Tap `Authorize Only`.
2. In ToroPass Wallet, tap `Deny`.
3. Confirm the example app shows `access_denied`.
4. Repeat and use the top-right `X` or system back.
5. Confirm the example app still maps the callback into a denied result.

## Reused Code

1. Tap `Authorize Only`.
2. Approve in ToroPass Wallet.
3. Tap `Exchange Stored Code`.
4. Tap `Exchange Stored Code` again with the same code.
5. Confirm the second exchange fails with the expected issuer error.

## Profile Fetch

1. Complete either `Verify Identity` or `Authorize Only` + `Exchange Stored Code`.
2. Tap `Fetch Profile`.
3. Confirm profile data returns with the expected wallet and KYC values.

## Revoked Consent

1. Complete a successful authorization and token exchange.
2. Revoke consent from ToroPass Wallet.
3. Return to the example app.
4. Tap `Fetch Profile`.
5. Confirm the request fails and the stored token should be treated as invalid.
