# ToroPass Client

Flutter client package for third-party apps that want to request ToroPass Wallet identity verification.

ToroPass Client launches the ToroPass Wallet OAuth consent flow, receives the app callback, exchanges the authorization code for an app-scoped OAuth token, and fetches the approved identity profile.

## Current Status

The package contract is defined. Deep link launch, callback capture, token exchange, profile fetch, and the example app are tracked in [tasks.md](tasks.md).

## Contract

Create a client with your OAuth app details:

```dart
final client = ToroPassClient(
  config: ToroPassClientConfig(
    clientId: 'toro_client_...',
    redirectUri: Uri.parse('myapp://toropass/callback'),
    scopes: const {
      ToroPassScope.kycStatus,
      ToroPassScope.wallet,
    },
  ),
);
```

Build or launch the ToroPass Wallet permission request:

```dart
final request = client.createAuthorizationRequest(
  appName: 'Example App',
);

print(request.launchUri);

final launchedRequest = await client.launchWallet(
  appName: 'Example App',
);

if (launchedRequest == null) {
  print('ToroPass Wallet is not installed or cannot be opened.');
  return;
}
```

Wait for the callback from ToroPass Wallet:

```dart
final callbackResult = await client.waitForCallback(launchedRequest);

switch (callbackResult) {
  case ToroPassAuthorizationCodeReceived(:final code):
    final session = await client.exchangeAuthorizationCode(code: code);
    print(session.token.accessToken);
    print(session.profile.wallet.tnsName);
  case ToroPassAuthDenied():
    print('User denied access.');
  case ToroPassAuthCancelled():
    print('No authorization code was returned.');
  case ToroPassAuthTimeout():
    print('ToroPass did not return in time.');
  case ToroPassAuthStateMismatch():
    print('Callback state did not match the request.');
  case ToroPassAuthTransportError(:final message):
    print(message);
  case ToroPassAuthSuccess():
    break;
}
```

The primary flow returns one of the typed auth results:

```dart
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
}
```

## Token Handling

The package exposes `fetchProfile(accessToken:)` for silent profile refresh with an existing OAuth app token.

Token persistence is intentionally left to the host app. Do not ship a `client_secret` in a Flutter app; the issuer accepts it only for server-side flows.

```dart
final profile = await client.fetchProfile(
  accessToken: session.token.accessToken,
);
```

## Wallet Deep Link

The default wallet launch URI is `toropass:/permission`.

Override `walletLaunchUri` in `ToroPassClientConfig` if your environment uses a different wallet scheme.
