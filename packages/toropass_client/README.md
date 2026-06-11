# ToroPass Client

`toropass_client` is a Flutter package for launching ToroPass Wallet OAuth identity verification flows from third-party apps.

Published package:

- https://pub.dev/packages/toropass_client

It handles:

- launching ToroPass Wallet through a native deep link
- receiving the callback URI in your app
- validating the OAuth `state`
- exchanging the authorization code for an app-scoped access token
- fetching the approved ToroPass profile

## Features

- `ToroPassClient.verifyIdentity()` for the one-call authorization flow
- `ToroPassClient.createAuthorizationRequest()` and `waitForCallback()` for lower-level control
- `ToroPassClient.exchangeAuthorizationCode()` and `fetchProfile()` for manual token/profile flows
- typed auth results for success, denial, cancellation, timeout, transport failure, and state mismatch
- `ToroPassButton` for lightweight UI integration
- `toStatusMessage()` for host-friendly result messaging

## Installation

```yaml
dependencies:
  toropass_client: ^0.1.1
```

Then run:

```sh
flutter pub get
```

## Quick Start

Before configuring `ToroPassClient`, create an OAuth app inside ToroPass Wallet and copy your app credentials:

- `client_id`
- app name
- callback / redirect URI

In ToroPass Wallet, open settings and tap the build number five times to unlock the Developer Dashboard, then create a new app.

Treat `client_secret` as sensitive. Do not ship it in client-side sample code or expose it publicly.

```dart
final client = ToroPassClient(
  config: ToroPassClientConfig(
    appName: 'Example App',
    clientId: 'toro_client_123',
    redirectUri: Uri.parse('myapp://oauth/callback'),
    scopes: const {
      ToroPassScope.kycStatus,
      ToroPassScope.wallet,
    },
  ),
);

final result = await client.verifyIdentity();

switch (result) {
  case ToroPassAuthSuccess(:final token, :final profile):
    print(token.accessToken);
    print(profile.wallet.tnsName);
  case ToroPassAuthDenied():
    print('User denied access.');
  case ToroPassAuthCancelled():
    print('User cancelled the flow.');
  case ToroPassAuthTimeout():
    print('ToroPass did not return in time.');
  case ToroPassAuthTransportError(:final message):
    print(message);
  case ToroPassAuthStateMismatch():
    print('Callback state mismatch.');
  case ToroPassAuthorizationCodeReceived():
    break;
}
```

## UI Helper

```dart
ToroPassButton(
  client: client,
  onResult: (result) {
    final status = result.toStatusMessage();
    debugPrint('${status.title}: ${status.message}');
  },
)
```

## Manual Flow

If you want more control over the handoff:

```dart
final request = client.createAuthorizationRequest();
final launched = await client.launchWallet(
  state: request.state,
);

if (launched == null) {
  print('ToroPass Wallet is unavailable.');
  return;
}

final callback = await client.waitForCallback(launched);

if (callback case ToroPassAuthorizationCodeReceived(:final code)) {
  final session = await client.exchangeAuthorizationCode(code: code);
  final profile = await client.fetchProfile(
    accessToken: session.token.accessToken,
  );
  print(profile.wallet.address);
}
```

## Native Setup

Your client app must do two things:

1. Register your callback URI scheme, for example `myapp://oauth/callback`
2. Allow wallet-scheme discovery for `toropass`

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

Add a visibility query so `canLaunchUrl` can detect ToroPass Wallet:

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

Allow wallet-scheme discovery:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>toropass</string>
</array>
```

## Tokens

`toropass_client` does not persist OAuth access tokens for you.

Host apps are responsible for deciding:

- where to store tokens
- how to refresh app state
- when to clear tokens after revocation or expiry

## Configuration Notes

- `appName` is required in `ToroPassClientConfig` and is sent to ToroPass Wallet as the requesting app label.
- The package currently uses the default ToroPass issuer base URL and wallet launch URI exposed by `ToroPassClientConfig`.

## Example

A runnable integration harness is included in [example](example/README.md).

There is also a manual [verification guide](verification-guide.md).
