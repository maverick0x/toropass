# ToroPass

ToroPass is a full-stack Toronet identity reference project.

It gives Flutter developers a working identity flow they can use today:
- a published Flutter SDK package for third-party apps on pub.dev
- a deployable ToroPass Wallet APK for end users
- an issuer-backed OAuth consent and identity verification flow
- the backend and wallet source code used to build the reference stack

## Start Here

If your goal is to understand or use ToroPass, do **not** start by cloning this repository and trying to run the entire stack end to end.

The most useful path is:
1. Install the published [`toropass_client`](https://pub.dev/packages/toropass_client) package in your Flutter app.
2. Install the ToroPass Wallet APK from the GitHub Releases page.
3. Register an OAuth app through ToroPass Wallet.
4. Launch the verification flow from your own Flutter app.

That is the primary value of this project: a deployed, usable identity reference that Flutter developers can integrate against without rebuilding the whole infrastructure locally.

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
- exchange the authorization code
- fetch the approved ToroPass profile

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

[Download ToroPass Wallet APK](https://github.com/maverick0x/toropass/releases/download/wallet-v1.0.1/toropass-wallet-v1.0.1.apk)

This is the recommended way to test the live holder-side experience without rebuilding the mobile app locally.

## Recommended Integration Path for Flutter Developers

If you are building a Flutter app on Toronet, this is the path ToroPass is optimized for:

1. Add [`toropass_client`](https://pub.dev/packages/toropass_client) to your Flutter app.
2. Configure your redirect URI / deep link.
3. Create a ToroPass OAuth app through the wallet.
4. Trigger the ToroPass verification flow from your app.
5. Receive the approved identity result back in your app.

This is the fastest way to adopt ToroPass, and it is the main reason this repository exists.

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

## Alignment

ToroPass is intended to serve as a production-grade reference for how Toronet identity can be implemented across:
- Flutter client apps
- a dedicated wallet
- a secure issuer backend
- reusable frontend and backend integration packages

The emphasis of this project is not just source availability. It is that the identity reference is already deployed and usable by Flutter developers today.
