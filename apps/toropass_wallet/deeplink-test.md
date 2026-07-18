# ToroPass Wallet Deep Link Test

Use this checklist to verify that third-party apps can open the wallet OAuth consent flow through the native `toropass` URL scheme.

## Test URL

```text
toropass:/permission?client_id=toro_client_test&redirect_uri=myapp%3A%2F%2Ftoropass%2Fcallback&scopes=kyc_status,wallet&state=test-state-123&app_name=Example%20App
```

Decoded payload:

- `client_id`: `toro_client_test`
- `redirect_uri`: `myapp://toropass/callback`
- `scopes`: `kyc_status,wallet`
- `state`: `test-state-123`
- `app_name`: `Example App`

## Android

Make sure the wallet app is installed on the emulator or device, then run:

```sh
adb shell am start \
  -a android.intent.action.VIEW \
  -c android.intent.category.BROWSABLE \
  -d "toropass:/permission?client_id=toro_client_test&redirect_uri=myapp%3A%2F%2Ftoropass%2Fcallback&scopes=kyc_status,wallet&state=test-state-123&app_name=Example%20App"
```

## iOS Simulator

Make sure the wallet app is installed on the simulator, then run:

```sh
xcrun simctl openurl booted "toropass:/permission?client_id=toro_client_test&redirect_uri=myapp%3A%2F%2Ftoropass%2Fcallback&scopes=kyc_status,wallet&state=test-state-123&app_name=Example%20App"
```

## Expected Behavior

- If the wallet session is active, the app should open directly to the permission screen.
- If the wallet session is not active, the app should route through sign-in and preserve the permission request query params.
- The permission screen should show `Example App` and request access to KYC status and wallet identity.
- Tapping `Deny`, the top-right `X`, or system back should open the callback URL with `error=access_denied` and `state=test-state-123`.
- Tapping `Allow` should call the issuer authorize endpoint, then open the callback URL with `code=<authorization-code>` and `state=test-state-123`.

## Notes

- The callback app must register the `myapp` scheme for the callback launch to succeed.
- The `state` query param is included for client-side correlation and should be echoed back in success and denial callbacks.
- Replace `client_id` and `redirect_uri` with a real developer app registration for full end-to-end testing.
