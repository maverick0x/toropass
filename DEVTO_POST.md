---
title: Add Sign in with ToroPass to Your Flutter App on Toronet
published: false
description: Use the published toropass_client package to launch ToroPass Wallet, get user consent, and fetch an approved identity profile in your Flutter app.
tags: flutter, web3, oauth, mobiledev
cover_image:
canonical_url:
---

If you are building a Flutter app on Toronet, one of the hardest things to get right is identity.

You need a way to:

- verify that a user really controls a Toro wallet
- request access to identity data with explicit consent
- avoid collecting raw KYC details directly in every app
- return the result cleanly back into your app

That is exactly what ToroPass is for.

ToroPass is a Toronet-native identity flow made up of:

- a wallet app for users
- an issuer backend that handles identity approval and consent enforcement
- a published Flutter SDK package for third-party apps: [`toropass_client`](https://pub.dev/packages/toropass_client)

The important part for Flutter developers is that you do not need to rebuild the whole stack to use it.

You can start with the published SDK package and the released ToroPass Wallet APK today.

## What the SDK Gives You

[`toropass_client`](https://pub.dev/packages/toropass_client) is the Flutter integration layer for ToroPass.

It handles:

- launching ToroPass Wallet from your app
- sending the authorization request
- listening for the callback into your app
- validating request state
- exchanging the authorization code
- fetching the approved ToroPass profile

In practice, it gives you a "Sign in with ToroPass" flow for Flutter apps on Toronet.

## How the Flow Works

At a high level:

1. Your Flutter app starts an identity request.
2. ToroPass Wallet opens.
3. The user approves or denies the request.
4. ToroPass Wallet deep-links back into your app.
5. Your app exchanges the code and reads the approved profile.

This keeps consent inside the wallet and keeps app integration lightweight.

## Install the SDK

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  toropass_client: ^0.1.1
```

Then run:

```sh
flutter pub get
```

Pub.dev package:

- https://pub.dev/packages/toropass_client

## Configure a Redirect URI

Your app needs a callback URI so ToroPass Wallet can route the user back after approval or denial.

Example:

```text
myapp://oauth/callback
```

You will register this in your app and use the same redirect URI when creating your ToroPass OAuth app.

## Quick Start in Flutter

Create a `ToroPassClient`:

```dart
final client = ToroPassClient(
  config: ToroPassClientConfig(
    appName: 'Example App',
    clientId: 'your_client_id',
    redirectUri: Uri.parse('myapp://oauth/callback'),
    scopes: const {
      ToroPassScope.kycStatus,
      ToroPassScope.wallet,
    },
  ),
);
```

Then trigger the one-call flow:

```dart
final result = await client.verifyIdentity();

switch (result) {
  case ToroPassAuthSuccess(:final token, :final profile):
    debugPrint('Access token: ${token.accessToken}');
    debugPrint('Wallet address: ${profile.wallet.address}');
    debugPrint('TNS name: ${profile.wallet.tnsName}');
  case ToroPassAuthDenied():
    debugPrint('User denied access.');
  case ToroPassAuthCancelled():
    debugPrint('User cancelled the flow.');
  case ToroPassAuthTimeout():
    debugPrint('ToroPass did not return in time.');
  case ToroPassAuthTransportError(:final message):
    debugPrint(message);
  case ToroPassAuthStateMismatch():
    debugPrint('Callback state mismatch.');
  case ToroPassAuthorizationCodeReceived():
    break;
}
```

That is the easiest path if you want a single entry point.

## Manual Flow If You Need More Control

If you want to separate wallet launch, callback handling, and token exchange:

```dart
final request = client.createAuthorizationRequest();
final launched = await client.launchWallet(
  state: request.state,
);

if (launched == null) {
  debugPrint('ToroPass Wallet is unavailable.');
  return;
}

final callback = await client.waitForCallback(launched);

if (callback case ToroPassAuthorizationCodeReceived(:final code)) {
  final session = await client.exchangeAuthorizationCode(code: code);
  final profile = await client.fetchProfile(
    accessToken: session.token.accessToken,
  );

  debugPrint(profile.wallet.address);
}
```

This is useful if your app needs finer-grained control over the authorization lifecycle.

## Native Setup

Your app needs two things:

1. a callback URI scheme like `myapp://oauth/callback`
2. wallet-scheme discovery for `toropass`

### Android

Register your callback URI in `AndroidManifest.xml`:

```xml
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data
      android:scheme="myapp"
      android:host="oauth"
      android:path="/callback" />
</intent-filter>
```

Add a visibility query so the app can detect ToroPass Wallet:

```xml
<queries>
  <intent>
    <action android:name="android.intent.action.VIEW" />
    <data android:scheme="toropass" />
  </intent>
</queries>
```

### iOS

Register your callback URI in `Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>myapp</string>
    </array>
  </dict>
</array>
```

Allow wallet discovery:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>toropass</string>
</array>
```

## What You Need Outside the SDK

To complete the flow end to end, you still need:

- ToroPass Wallet installed on the device
- an OAuth app created through ToroPass Wallet
- your real `clientId`
- your app redirect URI

Wallet APK:

- https://github.com/maverick0x/toropass/releases/download/wallet-v1.0.1/toropass-wallet-v1.0.1.apk

## Why This Matters for Toronet Apps

Without a shared identity layer, every Toronet app has to solve the same problems repeatedly:

- wallet identity verification
- consent UX
- KYC-aware onboarding
- secure app-to-app handoff

ToroPass moves that complexity into a reusable system:

- users complete identity actions in a dedicated wallet
- third-party apps request only what they need
- developers integrate through a small Flutter SDK instead of rebuilding identity from scratch

That is a much better developer experience and a much better privacy model for users.

## Useful Links

- SDK package: https://pub.dev/packages/toropass_client
- Root project README: https://github.com/maverick0x/toropass/blob/main/README.md
- SDK integration guide: https://github.com/maverick0x/toropass/blob/main/TOROPASS_SDK_INTEGRATION.md
- Example app README: https://github.com/maverick0x/toropass/blob/main/packages/toropass_client/example/README.md
- Wallet APK: https://github.com/maverick0x/toropass/releases/download/wallet-v1.0.1/toropass-wallet-v1.0.1.apk

## Closing

If you are building on Toronet with Flutter, the simplest way to adopt a proper identity flow today is:

1. install [`toropass_client`](https://pub.dev/packages/toropass_client)
2. install ToroPass Wallet
3. register your OAuth app
4. trigger the consent flow from your app

That gives you a working, Toronet-native identity path without having to build the entire infrastructure yourself.
