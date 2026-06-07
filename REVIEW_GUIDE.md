# ToroPass Review Guide

This guide is the fastest way for Toronet developers to understand, test, and integrate ToroPass without needing the private backend secrets used for the issuer infrastructure.

## Guide Goal

ToroPass should be approached primarily as a **deployed, usable Toronet identity reference** for Flutter developers, not as a clone-first monorepo that must be reproduced from scratch before anything can be tested.

The most important things to verify are:
- the published Flutter SDK package on pub.dev is usable
- the released ToroPass Wallet APK works as the holder app
- the OAuth-style consent flow works end to end
- the project clearly demonstrates Toronet-native identity architecture

## Recommended Path

### 1. Read the Core Docs

Start with:
- [Root README](README.md)
- [ToroPass SDK Integration Guide](TOROPASS_SDK_INTEGRATION.md)
- [`toropass_client` on pub.dev](https://pub.dev/packages/toropass_client)
- [ToroPass Client README](packages/toropass_client/README.md)
- [ToroPass Client Example README](packages/toropass_client/example/README.md)
- [Project Context](context/project.md)

### 2. Install the Wallet APK

Download and install the released Android wallet:

- [ToroPass Wallet APK](https://github.com/maverick0x/toropass/releases/download/wallet-v1.0.1/toropass-wallet-v1.0.1.apk)

This is the intended path for testing the holder-side experience.

### 3. Explore the Published Flutter Integration Surface

The published ToroPass SDK for third-party Flutter apps is [`toropass_client`](https://pub.dev/packages/toropass_client).

Developers should expect that the package provides a practical integration surface for:
- launching ToroPass Wallet
- initiating the consent request
- receiving the callback result
- exchanging the authorization code
- fetching the approved profile

### 4. Run the Example App

Use the example app under [packages/toropass_client/example](packages/toropass_client/example/).

The example exists to demonstrate:
- app-to-app launch from a Flutter client
- callback handling through a redirect URI
- authorization code exchange
- profile retrieval after user approval

### 5. Validate the Core User Flow

The primary end-to-end flow is:

1. Install ToroPass Wallet.
2. Create or validate a Toro identity in the wallet.
3. Complete the KYC flow in the wallet.
4. Register an OAuth app from the wallet developer dashboard.
5. Configure the third-party Flutter app with those credentials.
6. Trigger the ToroPass verification flow from the client app.
7. Approve or deny the request in ToroPass Wallet.
8. Confirm that the client app receives the expected callback result.

### 6. Inspect Privacy and Consent Controls

Developers should also inspect:
- connected app management inside the wallet
- consent revocation flow
- biometric lock flow
- developer app registration flow

## What You Can Verify Without Private Secrets

The following are intentionally reviewable without access to the private issuer environment:
- wallet app UX and feature flow
- third-party Flutter integration through the published `toropass_client` SDK
- deep-link callback flow
- OAuth-style consent flow
- source code structure and separation of concerns
- documentation quality

## What Is Private / Not Intended for a First Pass

The issuer backend depends on private infrastructure and secrets for:
- environment configuration
- database access
- admin credentials
- KYC authority operations

Because of that, a fully fresh local reproduction of the production-equivalent backend is **not** the recommended first path.

That is by design. ToroPass is being presented as a deployed reference implementation that Flutter developers can use directly.

## Developer Checklist

Use this checklist while exploring the project:

- `README.md` explains the project clearly
- the review path is reproducible without hidden setup assumptions
- the wallet APK installs and opens successfully
- the client package documentation is complete enough for another Flutter developer
- the example app demonstrates the intended integration path
- the consent flow is understandable and works as described
- the architecture clearly shows how Toronet identity flows through wallet, issuer, and client
- the repository is organized in a way another developer can extend

## Why This Matters for Toronet Builders

This path is useful because:
- the main flows work consistently
- the monorepo is structured into wallet, backend, and package boundaries
- developers can evaluate the system without reconstructing private infrastructure
- the guides explain both usage and architecture clearly
- Flutter developers can use the package and wallet as a real Toronet identity reference

## Optional Deep Source Dive

If you want to inspect implementation details, the most relevant areas are:
- [`toropass_client` on pub.dev](https://pub.dev/packages/toropass_client)
- [apps/toropass_wallet](apps/toropass_wallet/)
- [backend/toropass_issuer](backend/toropass_issuer/)
- [packages/toropass_client](packages/toropass_client/)

## Demo

Walkthrough video:

- [ToroPass Demo Video](https://youtu.be/wK3rkSzY9C8)
