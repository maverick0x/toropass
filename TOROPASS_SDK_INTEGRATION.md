# ToroPass SDK Integration Guide

This guide shows the intended way a Flutter developer integrates ToroPass today.

## What "ToroPass SDK" Means Here

For third-party Flutter developers, the ToroPass integration surface is the published [`toropass_client`](https://pub.dev/packages/toropass_client) package on pub.dev.

It handles:
- launching ToroPass Wallet
- passing the authorization request
- listening for the callback
- exchanging the returned authorization code
- retrieving the approved user profile

In other words, this is the practical "Sign in with ToroPass" SDK for Flutter apps.

## Recommended Integration Model

ToroPass is designed to be used with:
- the published [`toropass_client`](https://pub.dev/packages/toropass_client) package
- the installed ToroPass Wallet app
- an OAuth app created through ToroPass Wallet

The recommended mental model is:

1. Your Flutter app starts the identity request.
2. ToroPass Wallet handles user consent and identity approval.
3. Your app receives the callback and finishes the exchange.

## Integration Steps

### 1. Add the Package

Use the published [`toropass_client`](https://pub.dev/packages/toropass_client) package in your Flutter app.

See:
- [`toropass_client` on pub.dev](https://pub.dev/packages/toropass_client)
- [ToroPass Client README](packages/toropass_client/README.md)
- [ToroPass Client Example](packages/toropass_client/example/README.md)

### 2. Configure a Redirect URI

Your app needs a callback URI that your Flutter app can receive after ToroPass Wallet finishes the consent flow.

Example pattern:

```text
yourapp://oauth/callback
```

ToroPass Wallet uses that callback to return:
- success results after approval
- cancellation / denial results when the user rejects the request

### 3. Create an OAuth App in ToroPass Wallet

Before you create a `ToroPassClient` in your Flutter app, you need to create an OAuth app inside ToroPass Wallet.

Open ToroPass Wallet and go to the settings screen. Tap the build number five times to unlock the Developer Dashboard.

From the Developer Dashboard:

1. Choose **Create New App**.
2. Enter your app name.
3. Enter your callback URI, for example `yourapp://oauth/callback`.
4. Save the app.
5. Copy the generated app credentials.

You should keep track of:
- `client_id`
- `client_secret`
- app name
- callback / redirect URI

Your Flutter app uses the app name, `client_id`, and callback URI when configuring `ToroPassClient`.

Treat `client_secret` as a sensitive credential. Do not expose it in screenshots, public repositories, or client-side sample code. If your integration uses a backend token exchange, keep the secret on your backend instead of hard-coding it into a mobile app.

### 4. Launch the Verification Flow

From your Flutter app, use [`toropass_client`](https://pub.dev/packages/toropass_client) to:
- build an authorization request
- open ToroPass Wallet
- wait for the callback result

The package abstracts the deep-link handoff so your app does not need to manually rebuild the wallet launch flow.

### 5. Exchange the Authorization Code

After the user approves the request in ToroPass Wallet, your app receives an authorization code.

That code is then exchanged through the ToroPass flow so your app can fetch the approved user profile.

### 6. Read the Approved Profile

After a successful code exchange, your app receives the approved ToroPass identity data that the user consented to share.

## End-to-End Flow

At a high level:

1. The user installs ToroPass Wallet.
2. The user creates or validates a Toro identity.
3. The user completes KYC in the wallet.
4. Your Flutter app launches a ToroPass authorization request.
5. ToroPass Wallet presents the consent UI.
6. The user allows or denies the request.
7. ToroPass Wallet deep-links back to your app.
8. Your app exchanges the returned code and fetches the profile.

## What Your App Does Not Need To Handle

Using ToroPass means your Flutter app does **not** need to directly implement:
- user KYC collection
- wallet identity creation logic
- consent UI between verifier and holder
- wallet-to-app callback plumbing from scratch

That is the main developer-experience value of the project.

## Where Toronet Fits In

ToroPass is Toronet-native at the architecture level:
- the user identity originates from a Toro wallet / TNS context
- the wallet app is built around Toronet identity flows
- the issuer backend anchors verification using Toronet SDK integration
- the client package exists so Toronet Flutter apps can consume that identity flow cleanly

So while a Flutter developer mainly integrates [`toropass_client`](https://pub.dev/packages/toropass_client), the identity system behind that package is rooted in Toronet workflows rather than generic OAuth alone.

## Best Files to Read

If you want to inspect the integration surface directly, start here:
- [`toropass_client` on pub.dev](https://pub.dev/packages/toropass_client)
- [packages/toropass_client/README.md](packages/toropass_client/README.md)
- [packages/toropass_client/example/README.md](packages/toropass_client/example/README.md)
- [packages/toropass_client/lib](packages/toropass_client/lib/)

If you want the broader system context, also read:
- [README.md](README.md)
- [context/project.md](context/project.md)

## Testing Path

The easiest way to test the integration is:

1. Install the ToroPass Wallet APK.
2. Set up the example app in `packages/toropass_client/example`.
3. Configure it with a valid redirect URI and ToroPass app credentials.
4. Launch a verification request.
5. Confirm that approval returns control to the Flutter app with the expected result.

Wallet APK:

- [Download ToroPass Wallet APK](https://github.com/maverick0x/toropass/releases/download/wallet-v1.0.1/toropass-wallet-v1.0.1.apk)

## Who This Guide Is For

This guide is primarily for:
- Flutter developers integrating ToroPass into a mobile app
- Toronet ecosystem builders who want to understand the intended integration path quickly
