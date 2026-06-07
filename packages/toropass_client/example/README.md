# ToroPass Client Example

This example app exercises the wallet OAuth flow exposed by `toropass_client`.

## Callback URI

```text
toropassclient://oauth/callback
```

That scheme is registered in:

- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/Info.plist`

## What It Tests

- Launch ToroPass Wallet from a third-party app
- Complete the one-call `verifyIdentity()` flow
- Capture an authorization code without exchanging it immediately
- Exchange the stored code manually
- Reuse the same code to verify issuer rejection behavior
- Fetch the approved OAuth profile with the stored app token

## Run

From this directory:

```sh
flutter pub get
flutter run
```

Use a real `client_id` and make sure the issuer knows the callback URI `toropassclient://oauth/callback`.

For the full end-to-end simulator and device checklist, see the package
[`verification-guide.md`](../verification-guide.md).
