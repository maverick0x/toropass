# ToroPass Wallet

ToroPass Wallet is the holder app for ToroPass. Users create or validate a Toronet wallet identity, complete KYC, manage connected apps, and approve OAuth-style consent requests from third-party Flutter apps using `toropass_client`.

## Features

- Toronet wallet creation and validation
- KYC submission through the ToroPass issuer backend
- OAuth consent approval for third-party apps
- Connected app listing and consent revocation
- Hidden developer dashboard for OAuth app registration
- Biometric protection and secure token storage
- Native deep link handling for `toropass:/permission`

## SDKs Used

- `toronet`: Toronet Flutter SDK for wallet-related checks and Toronet identity integration
- `flutter_dotenv`: loads local `.env` values
- `dio`: issuer API requests
- `flutter_riverpod`: state management
- `local_auth` and `flutter_secure_storage`: biometric protection and secure storage

## Prerequisites

- Flutter SDK matching `pubspec.yaml` (`sdk: ^3.11.5`)
- Android Studio or Xcode for device/simulator builds
- A running ToroPass issuer backend, or access to the deployed issuer
- Issuer `APP_API_KEY` and `APP_SECRET` values for signed first-party requests

## Environment

Create a local env file:

```bash
cp .env.example .env
```

Required values:

- `APP_API_KEY`: shared key accepted by the issuer backend
- `APP_SECRET`: HMAC secret used to sign wallet requests

The current app build points at the deployed issuer API in `lib/core/network/endpoints.dart`:

```text
https://api.toropass.app/api/v1/
```

For local backend testing, change `ApiEndpoints.BASE_URL` to your local issuer URL, usually:

```text
http://localhost:3000/api/v1/
```

## Install And Run

From this directory:

```bash
flutter pub get
flutter run
```

For Android release signing, copy the signing template and fill in local values:

```bash
cp android/key.properties.example android/key.properties
```

Release builds fail when the properties file, any required signing value, or
the referenced keystore is missing. Debug builds do not require release signing
material.

## Toronet Integration

The wallet is the user-facing Toronet identity holder. It uses Toronet identity concepts through the issuer-backed flow:

- the wallet creates or validates a Toronet wallet identity
- the issuer anchors KYC state through its Toronet SDK integration
- the wallet stores the active wallet network returned by the backend
- third-party apps request consent through `toropass:/permission`
- approved apps receive an OAuth code through their callback URI

## Demo And Testing

- Released APK: https://github.com/mav3rickx/toropass/releases/download/wallet-v1.0.1/toropass-wallet-v1.0.1.apk
- Review guide: ../../REVIEW_GUIDE.md
- Deep link test notes: ./deeplink-test.md
- Backend contract: ./backend_contract.md

## Troubleshooting

- If requests fail with auth or HMAC errors, confirm wallet `.env` values match backend `APP_API_KEY` and `APP_SECRET`.
- If the app cannot reach a local backend from an Android emulator, use `http://10.0.2.2:3000/api/v1/` instead of `localhost`.
- If wallet consent links do not open the app, verify the native `toropass` scheme registration in Android/iOS and reinstall the app.
- If callbacks do not return to a client app, confirm the third-party app registered the same redirect URI used when creating the OAuth app.
