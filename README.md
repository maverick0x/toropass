# ToroPass

ToroPass is a full-stack Toronet identity reference project.

License: [Apache-2.0](LICENSE)

It gives Flutter developers a working identity flow they can use today:
- a published Flutter SDK package for third-party apps on pub.dev
- a deployable ToroPass Wallet APK for end users
- an issuer-backed OAuth consent and identity verification flow
- the backend and wallet source code used to build the reference stack

## Start Here

If you only want to integrate ToroPass into a Flutter app, start with the published package:

[`toropass_client` on pub.dev](https://pub.dev/packages/toropass_client)

You do **not** need to run this monorepo locally to use ToroPass. The intended integration path is the deployed ToroPass flow: the pub.dev package, the released wallet APK, and the live issuer service.

The most useful path is:
1. Install the published [`toropass_client`](https://pub.dev/packages/toropass_client) package in your Flutter app.
2. Install the ToroPass Wallet APK from the GitHub Releases page.
3. Create an OAuth app through ToroPass Wallet.
4. Launch the verification flow from your own Flutter app.

That is the primary value of this project: a deployed, usable identity reference that Flutter developers can integrate against without rebuilding the whole infrastructure locally.

Usage Guide:
- [Integration article](https://dev.to/maverick_3_0/add-sign-in-with-toropass-to-your-flutter-app-on-toronet-50eh)

- [![Watch the ToroPass Toronet demo](https://img.youtube.com/vi/tLzgTVgMZBE/maxresdefault.jpg)](https://youtu.be/tLzgTVgMZBE)

- [ToroPass Client Example README](packages/toropass_client/example/README.md)

**Demo video:** [ToroPass: Full-Stack Toronet Identity Reference Demo](https://youtu.be/tLzgTVgMZBE)

## Why This Exists

ToroPass is designed to be the identity layer for the Toronet ecosystem.

Instead of every Toronet app building its own KYC collection, consent, and wallet-auth flow, ToroPass separates identity from application logic:
- users complete verification once in a dedicated wallet
- developers request permissioned identity access through OAuth-style consent
- apps verify identity state without handling raw KYC documents directly

## What Is Already Usable

### 1. ToroPass Client Package

The published Flutter SDK package is intended for third-party Flutter developers.

Use it to:
- launch ToroPass Wallet
- request user consent
- receive the OAuth callback
- protect the authorization code with S256 PKCE
- exchange the authorization code
- fetch only the ToroPass profile fields covered by approved scopes

See:
- [`toropass_client` on pub.dev](https://pub.dev/packages/toropass_client)
- [ToroPass Client README](packages/toropass_client/README.md)
- [ToroPass Client Example README](packages/toropass_client/example/README.md)

### 2. ToroPass Wallet APK

ToroPass Wallet is the holder app in this system.

Users can:
- create or validate a Toro wallet identity
- complete KYC
- manage connected apps
- approve or deny OAuth consent requests
- enable biometric protection

For most testers and Flutter developers, the released APK is the correct way to use ToroPass.

### 3. Download the Wallet APK

The released Android wallet can be downloaded directly here:

[Download ToroPass Wallet APK](https://github.com/mav3rickx/toropass/releases/download/wallet-v1.0.1/toropass-wallet-v1.0.1.apk)

This is the recommended way to test the live holder-side experience without rebuilding the mobile app locally.

## Recommended Integration Path for Flutter Developers

If you are building a Flutter app on Toronet, this is the path ToroPass is optimized for:

1. Add [`toropass_client`](https://pub.dev/packages/toropass_client) to your Flutter app.
2. Configure your redirect URI / deep link.
3. Create a ToroPass OAuth app through the wallet.
4. Trigger the ToroPass verification flow from your app.
5. Receive the approved identity result back in your app.

This is the fastest way to adopt ToroPass, and it is the main reason this repository exists.

The SDK generates and preserves the PKCE verifier automatically. Developers
using the manual flow must keep the returned authorization request and pass its
`codeVerifier` during code exchange.

## Create Your ToroPass OAuth App

Before you configure `ToroPassClient` in your Flutter app, you need to create an OAuth app inside ToroPass Wallet.

Open ToroPass Wallet and go to the settings screen. Tap the build number five times to unlock the Developer Dashboard.

From the Developer Dashboard:

1. Choose **Create New App**.
2. Enter your app name.
3. Enter your callback URI, for example `myapp://oauth/callback`.
4. Save the app.
5. Copy the generated app credentials.

You should keep track of:
- `client_id`
- `client_secret`
- app name
- callback URI

Your Flutter app uses the app name, `client_id`, and callback URI when configuring `ToroPassClient`.

Treat `client_secret` as a sensitive credential. Do not expose it in public repositories, screenshots, or client-side sample code. If your architecture uses a backend token exchange, keep the secret on your backend instead of hard-coding it into a mobile app.

## Repository Overview

This monorepo contains the full reference implementation:

### `apps/toropass_wallet`

The Flutter mobile wallet used by end users.

Responsibilities:
- wallet onboarding
- KYC submission
- consent management
- biometric lock
- OAuth app registration for developers
- OAuth approval for users

### `backend/toropass_issuer`

The NestJS issuer backend and authority service.

Responsibilities:
- wallet validation support
- token issuance and refresh
- KYC processing
- OAuth app registration
- OAuth consent enforcement
- profile access for approved clients

### `packages/toropass_client`

The source code for the published Flutter SDK used by third-party Flutter apps.

Responsibilities:
- wallet launch
- callback handling
- code exchange
- profile retrieval

### `packages/toropass_verifier`

This package is **planned for future work**.

The intended goal is a backend-side verifier package for Node.js services in the Toronet ecosystem, but it is not yet part of the completed reference implementation delivered here.

## Architecture Summary

ToroPass has four roles:

1. **Holder**
   The ToroPass Wallet holds the user’s identity and handles consent.

2. **Authority**
   The issuer backend validates and anchors identity state.

3. **Client**
   The Flutter package gives third-party apps a simple integration surface.

4. **Verifier**
   This is a planned future component for ecosystem backends, not a completed part of the current deliverable.

## End-to-End Flow

At a high level:

1. A user creates or validates a Toro wallet in ToroPass Wallet.
2. The user completes KYC in ToroPass Wallet.
3. A third-party Flutter app uses `toropass_client` to request verification.
4. ToroPass Wallet opens and presents the consent screen.
5. The user allows or denies the request.
6. The third-party app receives the callback result.
7. The app exchanges the code and fetches the approved profile.

## Local Development Note

This repository includes the full source code, but a complete local clone of the entire production-equivalent stack is **not** the intended first experience for most developers.

Why:
- the backend depends on private environment configuration
- KYC and admin flows require secrets and infrastructure you will not have by default
- reproducing production end to end locally requires your own credentials, database, and service setup

So the better mental model is:
- use the **deployed stack** to integrate and evaluate ToroPass
- use the **source code** to learn architecture, extend the system, or contribute

## When to Clone the Repository

Clone this repository if you want to:
- study the full architecture
- contribute to ToroPass itself
- self-host a ToroPass-like stack with your own secrets and infra
- inspect how the Toronet Flutter and JS SDKs fit into a real product

## Best Entry Points

For usage:
- [`toropass_client` on pub.dev](https://pub.dev/packages/toropass_client)
- [ToroPass Client README](packages/toropass_client/README.md)
- [ToroPass Client Example README](packages/toropass_client/example/README.md)
- [ToroPass SDK Integration Guide](TOROPASS_SDK_INTEGRATION.md)
- [ToroPass Review Guide](REVIEW_GUIDE.md)

For architecture:
- [Project Context](context/project.md)

For wallet integration work:
- [ToroPass Wallet Tasks](apps/toropass_wallet/tasks.md)

## Prerequisites

For the recommended deployed integration path:

- Flutter SDK for building a third-party Flutter app
- Android device or emulator for installing ToroPass Wallet
- The published [`toropass_client`](https://pub.dev/packages/toropass_client) package
- The released [ToroPass Wallet APK](https://github.com/mav3rickx/toropass/releases/download/wallet-v1.0.1/toropass-wallet-v1.0.1.apk)
- A callback URI for your app, for example `myapp://oauth/callback`

For source-code development:

- Flutter SDK matching the wallet and package `pubspec.yaml` files
- Dart / Flutter tooling for the wallet and package example
- Node.js and `pnpm` for the issuer backend
- PostgreSQL for a local issuer database
- Toronet admin credentials if you want to run KYC anchoring locally
- Local `.env` files copied from the provided `.env.example` templates

## Installation

### Use ToroPass From A Flutter App

Add the published package to your Flutter app:

```yaml
dependencies:
  toropass_client: ^0.2.0
```

Then run:

```bash
flutter pub get
```

Install the wallet APK on an Android device:

```text
https://github.com/mav3rickx/toropass/releases/download/wallet-v1.0.1/toropass-wallet-v1.0.1.apk
```

Create an OAuth app inside ToroPass Wallet, copy the generated `client_id`, and configure `ToroPassClient` in your Flutter app.

### Clone The Source

Clone this repository if you want to inspect or extend the implementation:

```bash
git clone https://github.com/mav3rickx/toropass.git
cd toropass
```

Install workspace dependencies as needed:

```bash
flutter pub get
pnpm install
```

You do not need to run the whole backend locally to test the normal third-party Flutter integration. The deployed issuer and wallet APK are the intended path for using ToroPass today.

## Environment Variables

Example env files are provided for local source development:

- [Wallet env example](apps/toropass_wallet/.env.example)
- [Issuer env example](backend/toropass_issuer/.env.example)

Wallet values:

- `APP_API_KEY`: shared key sent to the issuer backend
- `APP_SECRET`: HMAC secret used to sign first-party wallet requests

Issuer values:

- `DATABASE_URL`: PostgreSQL connection string used by Prisma
- `APP_API_KEY`: shared API key required by protected issuer routes
- `APP_SECRET`: HMAC signing secret for first-party wallet requests
- `JWT_SECRET`: signing secret for first-party wallet JWTs
- `BLOCKCHAIN_NETWORK`: Toronet SDK network, usually `testnet` or `mainnet`
- `TESTNET_ADMIN_ADDRESS` / `TESTNET_ADMIN_PASSWORD`: Toronet testnet admin credentials
- `MAINNET_ADMIN_ADDRESS` / `MAINNET_ADMIN_PASSWORD`: Toronet mainnet admin credentials
- `PORT`: local backend port, defaults to `3000`
- `SLACK_WEBHOOK_URL`: optional alert webhook

Create local env files from the templates:

```bash
cp apps/toropass_wallet/.env.example apps/toropass_wallet/.env
cp backend/toropass_issuer/.env.example backend/toropass_issuer/.env
```

Do not commit real `.env` files or private Toronet admin credentials.

## How To Run

### Recommended: Test The Deployed Flow

This is the fastest way to use ToroPass:

1. Install the released ToroPass Wallet APK.
2. Open ToroPass Wallet and create or validate a Toro identity.
3. Complete the wallet-side KYC flow.
4. Open wallet settings and tap the build number five times to unlock the Developer Dashboard.
5. Create an OAuth app with your callback URI, for example `myapp://oauth/callback`.
6. Add `toropass_client` to your Flutter app.
7. Configure your app with the generated `client_id`, app name, callback URI, and desired scopes.
8. Launch `ToroPassClient.verifyIdentity()`.
9. Approve the request in ToroPass Wallet.
10. Receive the callback, exchange the code, and fetch the approved profile.

Package docs:

- [`toropass_client` on pub.dev](https://pub.dev/packages/toropass_client)
- [Package README](packages/toropass_client/README.md)
- [Example app README](packages/toropass_client/example/README.md)

### Run The Package Example

From the example app:

```bash
cd packages/toropass_client/example
flutter pub get
flutter run
```

The example callback URI is:

```text
toropassclient://oauth/callback
```

Create the OAuth app in ToroPass Wallet with that exact callback URI, then place the generated client values in the example app before running the flow.

### Run The Wallet App From Source

From the wallet app:

```bash
cd apps/toropass_wallet
cp .env.example .env
flutter pub get
flutter run
```

The current wallet source points to the deployed issuer API:

```text
https://api.toropass.app/api/v1/
```

For local backend testing, update `ApiEndpoints.BASE_URL` in `apps/toropass_wallet/lib/core/network/endpoints.dart` to your local issuer URL, for example:

```text
http://localhost:3000/api/v1/
```

On an Android emulator, use:

```text
http://10.0.2.2:3000/api/v1/
```

### Run The Issuer Backend Locally

Local issuer setup is useful for development and self-hosting work, but it requires your own PostgreSQL database and Toronet credentials.

```bash
cd backend/toropass_issuer
cp .env.example .env
pnpm install
pnpm prisma generate
pnpm run start:dev
```

Optional SDK connectivity check:

```bash
pnpm run config
```

The backend API base path is:

```text
http://localhost:3000/api/v1/
```

## How Toronet SDK Is Integrated

ToroPass uses Toronet at the identity and verification layers:

- The wallet flow is built around Toro wallet identity and TNS-style user identity.
- The wallet source depends on the `toronet` Flutter SDK for wallet-related Toronet checks.
- The issuer backend depends on the `torosdk` TypeScript package.
- The issuer selects the active Toronet network from `BLOCKCHAIN_NETWORK`.
- KYC verification is anchored through admin-backed Toronet SDK calls from the issuer.
- The wallet and client package expose the Toronet-native identity result through an OAuth-style consent flow.

The important separation is that third-party Flutter apps do not need to call Toronet SDK methods directly just to request identity. They use `toropass_client`; ToroPass Wallet and the issuer handle the Toronet-specific work behind the consent flow.

## Demo Links

- [ToroPass Wallet APK](https://github.com/mav3rickx/toropass/releases/download/wallet-v1.0.1/toropass-wallet-v1.0.1.apk)
- [`toropass_client` on pub.dev](https://pub.dev/packages/toropass_client)
- [Demo walkthrough video](https://youtu.be/wK3rkSzY9C8)
- [Architecture overview image](toropass-architecture-overview.png)
- [SDK Integration Guide](TOROPASS_SDK_INTEGRATION.md)
- [Package example app](packages/toropass_client/example/README.md)

## Troubleshooting

- If the wallet is not opened from a Flutter app, confirm the wallet APK is installed and your app allows discovery of the `toropass` URL scheme.
- If callbacks do not return to your app, confirm the redirect URI in your native Android/iOS config exactly matches the callback URI used when creating the ToroPass OAuth app.
- If the package reports a state mismatch, restart the flow and make sure callbacks from older attempts are not being reused.
- If token exchange fails, confirm the authorization code has not already been used. OAuth codes are single-use.
- If local wallet requests fail with auth or HMAC errors, make sure wallet `APP_API_KEY` and `APP_SECRET` match the issuer backend values.
- If the Android emulator cannot reach a local issuer at `localhost`, use `10.0.2.2`.
- If local issuer startup fails, check `DATABASE_URL`, run `pnpm prisma generate`, and make sure PostgreSQL is running.
- If Toronet KYC anchoring fails locally, confirm `BLOCKCHAIN_NETWORK` and the matching admin address/password are set correctly.

## Alignment

ToroPass is intended to serve as a production-grade reference for how Toronet identity can be implemented across:
- Flutter client apps
- a dedicated wallet
- a secure issuer backend
- reusable frontend and backend integration packages

The emphasis of this project is not just source availability. It is that the identity reference is already deployed and usable by Flutter developers today.
