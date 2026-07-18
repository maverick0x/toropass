import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toropass_client/toropass_client.dart';

void main() {
  group('ToroPassClientConfig', () {
    test('sets safe defaults for issuer, scopes, and timeout', () {
      final config = ToroPassClientConfig(
        appName: 'Example App',
        clientId: ' toro_client_123 ',
        redirectUri: Uri.parse('myapp://toropass/callback'),
      );

      expect(config.clientId, 'toro_client_123');
      expect(config.redirectUri.toString(), 'myapp://toropass/callback');
      expect(
        config.issuerBaseUrl.toString(),
        'https://api.toropass.app/api/v1',
      );
      expect(config.walletLaunchUri.toString(), 'toropass:/permission');
      expect(config.scopes, ToroPassClientConfig.defaultScopes);
      expect(config.scopeValues, ['kyc_status', 'wallet']);
      expect(config.callbackTimeout, const Duration(minutes: 2));
    });

    test('allows custom scopes while keeping default endpoints', () {
      final config = ToroPassClientConfig(
        appName: 'Example App',
        clientId: 'toro_client_123',
        redirectUri: Uri.parse('myapp://callback'),
        scopes: {ToroPassScope.kycStatus},
      );

      expect(
        config.issuerBaseUrl.toString(),
        'https://api.toropass.app/api/v1',
      );
      expect(config.walletLaunchUri.toString(), 'toropass:/permission');
      expect(config.scopeValues, ['kyc_status']);
    });

    test('rejects incomplete config', () {
      expect(
        () => ToroPassClientConfig(
          clientId: '',
          appName: 'Example App',
          redirectUri: Uri.parse('myapp://callback'),
        ),
        throwsArgumentError,
      );

      expect(
        () => ToroPassClientConfig(
          clientId: 'toro_client_123',
          redirectUri: Uri.parse('/callback'),
          appName: 'Example App',
        ),
        throwsArgumentError,
      );

      expect(
        () => ToroPassClientConfig(
          clientId: 'toro_client_123',
          redirectUri: Uri.parse('myapp://callback'),
          scopes: const {},
          appName: 'Example App',
        ),
        throwsArgumentError,
      );
    });
  });

  group('ToroPass result contract', () {
    test('success exposes OAuth token and profile', () {
      final result = ToroPassAuthSuccess(
        token: const ToroPassOAuthToken(accessToken: 'toro_tk_123'),
        profile: ToroPassProfile.fromJson(const {
          'id': 'user-1',
          'kycVerified': true,
          'wallet': {
            'address': '0x123',
            'tnsName': 'alice',
            'network': 'testnet',
          },
        }),
      );

      expect(result.isSuccess, isTrue);
      expect(result.token.accessToken, 'toro_tk_123');
      expect(result.profile.wallet.tnsName, 'alice');
    });

    test('non-success states are distinguishable', () {
      expect(const ToroPassAuthDenied(), isA<ToroPassAuthDenied>());
      expect(const ToroPassAuthCancelled(), isA<ToroPassAuthCancelled>());
      expect(
        ToroPassAuthTimeout(const Duration(seconds: 30)),
        isA<ToroPassAuthTimeout>(),
      );
      expect(
        const ToroPassAuthTransportError(message: 'Network unavailable'),
        isA<ToroPassAuthTransportError>(),
      );
    });

    test('maps denied and transport states into host-friendly messages', () {
      final denied = const ToroPassAuthDenied().toStatusMessage();
      final failed = const ToroPassAuthTransportError(
        message: 'Network unavailable',
      ).toStatusMessage();

      expect(denied.title, 'Access denied');
      expect(denied.tone, ToroPassStatusTone.warning);
      expect(failed.message, 'Network unavailable');
      expect(failed.tone, ToroPassStatusTone.error);
    });
  });

  group('ToroPass wallet launch transport', () {
    test('builds a wallet permission URI with OAuth query parameters', () {
      final client = ToroPassClient(
        config: ToroPassClientConfig(
          appName: 'Example App',
          clientId: 'toro_client_123',
          redirectUri: Uri.parse('myapp://toropass/callback'),
        ),
      );

      final request = client.createAuthorizationRequest(
        state: 'state-123',
      );

      expect(request.state, 'state-123');
      expect(request.launchUri.scheme, 'toropass');
      expect(request.launchUri.path, '/permission');
      expect(request.launchUri.queryParameters['client_id'], 'toro_client_123');
      expect(
        request.launchUri.queryParameters['redirect_uri'],
        'myapp://toropass/callback',
      );
      expect(request.launchUri.queryParameters['scopes'], 'kyc_status,wallet');
      expect(request.launchUri.queryParameters['state'], 'state-123');
      expect(request.launchUri.queryParameters['app_name'], 'Example App');
    });

    test('launches wallet when available', () async {
      final launcher = _FakeWalletLauncher(canLaunchResult: true);
      final client = ToroPassClient(
        config: ToroPassClientConfig(
          appName: 'Example App',
          clientId: 'toro_client_123',
          redirectUri: Uri.parse('myapp://callback'),
        ),
        walletLauncher: launcher,
      );

      final request = await client.launchWallet(state: 'state-123');

      expect(request, isNotNull);
      expect(launcher.launchedUri, request!.launchUri);
    });

    test('returns null when wallet is unavailable', () async {
      final launcher = _FakeWalletLauncher(canLaunchResult: false);
      final client = ToroPassClient(
        config: ToroPassClientConfig(
          appName: 'Example App',
          clientId: 'toro_client_123',
          redirectUri: Uri.parse('myapp://callback'),
        ),
        walletLauncher: launcher,
      );

      final request = await client.launchWallet(state: 'state-123');

      expect(request, isNull);
      expect(launcher.launchedUri, isNull);
    });
  });

  group('ToroPass callback capture', () {
    test('parses authorization code callbacks', () {
      final client = _buildClient();

      final result = client.parseCallbackUri(
        Uri.parse('myapp://callback?code=auth-code-123&state=state-123'),
        expectedState: 'state-123',
      );

      expect(result, isA<ToroPassAuthorizationCodeReceived>());
      final codeResult = result as ToroPassAuthorizationCodeReceived;
      expect(codeResult.code, 'auth-code-123');
      expect(codeResult.state, 'state-123');
    });

    test('parses denied callbacks', () {
      final client = _buildClient();

      final result = client.parseCallbackUri(
        Uri.parse(
          'myapp://callback?error=access_denied&error_description=Denied&state=state-123',
        ),
        expectedState: 'state-123',
      );

      expect(result, isA<ToroPassAuthDenied>());
      final denied = result as ToroPassAuthDenied;
      expect(denied.error, 'access_denied');
      expect(denied.description, 'Denied');
    });

    test('maps empty callbacks to cancelled', () {
      final client = _buildClient();

      final result = client.parseCallbackUri(
        Uri.parse('myapp://callback?state=state-123'),
        expectedState: 'state-123',
      );

      expect(result, isA<ToroPassAuthCancelled>());
    });

    test('rejects callbacks with mismatched state', () {
      final client = _buildClient();

      final result = client.parseCallbackUri(
        Uri.parse('myapp://callback?code=auth-code-123&state=other-state'),
        expectedState: 'state-123',
      );

      expect(result, isA<ToroPassAuthStateMismatch>());
      final mismatch = result as ToroPassAuthStateMismatch;
      expect(mismatch.expectedState, 'state-123');
      expect(mismatch.actualState, 'other-state');
    });

    test('waits for the matching redirect URI callback', () async {
      final listener = _FakeCallbackListener();
      final client = _buildClient(callbackListener: listener);
      final request = client.createAuthorizationRequest(state: 'state-123');

      final resultFuture = client.waitForCallback(request);
      listener.add(
        Uri.parse('otherapp://callback?code=ignored&state=state-123'),
      );
      listener.add(
        Uri.parse('myapp://callback?code=auth-code-123&state=state-123'),
      );

      final result = await resultFuture;

      expect(result, isA<ToroPassAuthorizationCodeReceived>());
      expect(
        (result as ToroPassAuthorizationCodeReceived).code,
        'auth-code-123',
      );
      await listener.close();
    });

    test('times out when no callback is received', () async {
      final listener = _FakeCallbackListener();
      final client = _buildClient(callbackListener: listener);
      final request = client.createAuthorizationRequest(state: 'state-123');

      final result = await client.waitForCallback(
        request,
        timeout: const Duration(milliseconds: 5),
      );

      expect(result, isA<ToroPassAuthTimeout>());
      await listener.close();
    });
  });

  group('ToroPass OAuth API flow', () {
    test('exchanges authorization code for token and profile', () async {
      final httpClient = _FakeHttpClient();
      final client = _buildClient(httpClient: httpClient);

      final session = await client.exchangeAuthorizationCode(
        code: ' auth-code-123 ',
      );

      expect(
        httpClient.lastPostUri.toString(),
        'https://api.toropass.app/api/v1/oauth/token',
      );
      expect(httpClient.lastPostBody, {
        'client_id': 'toro_client_123',
        'code': 'auth-code-123',
        'redirect_uri': 'myapp://callback',
      });
      expect(session.token.accessToken, 'toro_tk_123');
      expect(session.profile.id, 'user-1');
      expect(session.profile.wallet.address, '0x123');
    });

    test('includes optional client secret for server-side exchange', () async {
      final httpClient = _FakeHttpClient();
      final client = _buildClient(httpClient: httpClient);

      await client.exchangeAuthorizationCode(
        code: 'auth-code-123',
        clientSecret: ' toro_sk_123 ',
      );

      expect(httpClient.lastPostBody?['client_secret'], 'toro_sk_123');
    });

    test('fetches profile with app-scoped OAuth token', () async {
      final httpClient = _FakeHttpClient();
      final client = _buildClient(httpClient: httpClient);

      final profile = await client.fetchProfile(accessToken: ' toro_tk_123 ');

      expect(
        httpClient.lastGetUri.toString(),
        'https://api.toropass.app/api/v1/oauth/profile',
      );
      expect(httpClient.lastGetHeaders, {
        'Authorization': 'Bearer toro_tk_123',
      });
      expect(profile.kycVerified, isTrue);
      expect(profile.wallet.tnsName, 'alice');
    });

    test('surfaces expired or revoked OAuth tokens', () async {
      final httpClient = _FakeHttpClient(
        getError: const ToroPassTokenInvalidException(statusCode: 401),
      );
      final client = _buildClient(httpClient: httpClient);

      expect(
        () => client.fetchProfile(accessToken: 'toro_tk_revoked'),
        throwsA(isA<ToroPassTokenInvalidException>()),
      );
    });

    test(
      'verifyIdentity launches wallet, waits for code, exchanges token, and returns success',
      () async {
        final launcher = _FakeWalletLauncher(canLaunchResult: true);
        final listener = _FakeCallbackListener();
        final httpClient = _FakeHttpClient();
        final client = _buildClient(
          callbackListener: listener,
          walletLauncher: launcher,
          httpClient: httpClient,
        );

        final resultFuture = client.verifyIdentity();
        final launchedUri = await _waitFor(() => launcher.launchedUri);
        listener.add(
          Uri.parse(
            'myapp://callback?code=auth-code-123&state=${launchedUri.queryParameters['state']}',
          ),
        );

        final result = await resultFuture;

        expect(result, isA<ToroPassAuthSuccess>());
        expect((result as ToroPassAuthSuccess).profile.wallet.tnsName, 'alice');
        await listener.close();
      },
    );
  });

  group('ToroPassButton', () {
    testWidgets('runs verifyIdentity and reports the result', (tester) async {
      final launcher = _FakeWalletLauncher(canLaunchResult: true);
      final listener = _FakeCallbackListener();
      final httpClient = _FakeHttpClient();
      final client = _buildClient(
        callbackListener: listener,
        walletLauncher: launcher,
        httpClient: httpClient,
      );
      ToroPassAuthResult? capturedResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToroPassButton(
              client: client,
              onResult: (result) => capturedResult = result,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ToroPassButton));
      await tester.pump();

      expect(find.text('Opening ToroPass...'), findsOneWidget);

      final launchedUri = await _waitFor(() => launcher.launchedUri);
      await tester.pump();
      listener.add(
        Uri.parse(
          'myapp://callback?code=auth-code-123&state=${launchedUri.queryParameters['state']}',
        ),
      );

      await _waitFor(() => capturedResult);
      await tester.pump();

      expect(capturedResult, isA<ToroPassAuthSuccess>());
      expect(find.text('Verify with ToroPass'), findsOneWidget);
      await listener.close();
    });
  });
}

ToroPassClient _buildClient({
  ToroPassCallbackListener? callbackListener,
  ToroPassWalletLauncher? walletLauncher,
  ToroPassHttpClient? httpClient,
}) {
  return ToroPassClient(
    config: ToroPassClientConfig(
      appName: 'Example App',
      clientId: 'toro_client_123',
      redirectUri: Uri.parse('myapp://callback'),
    ),
    callbackListener: callbackListener,
    walletLauncher: walletLauncher,
    httpClient: httpClient,
  );
}

class _FakeWalletLauncher implements ToroPassWalletLauncher {
  final bool canLaunchResult;
  Uri? launchedUri;

  _FakeWalletLauncher({required this.canLaunchResult});

  @override
  Future<bool> canLaunch(Uri uri) async => canLaunchResult;

  @override
  Future<bool> launch(Uri uri) async {
    launchedUri = uri;
    return true;
  }
}

class _FakeCallbackListener implements ToroPassCallbackListener {
  final _controller = StreamController<Uri>();

  @override
  Stream<Uri> get uriStream => _controller.stream;

  void add(Uri uri) => _controller.add(uri);

  Future<void> close() => _controller.close();
}

class _FakeHttpClient implements ToroPassHttpClient {
  final Object? getError;
  Uri? lastPostUri;
  Map<String, dynamic>? lastPostBody;
  Uri? lastGetUri;
  Map<String, String>? lastGetHeaders;

  _FakeHttpClient({this.getError});

  @override
  Future<Map<String, dynamic>> postJson(
    Uri uri, {
    required Map<String, dynamic> body,
  }) async {
    lastPostUri = uri;
    lastPostBody = body;
    return {
      'status': 'success',
      'data': {'accessToken': 'toro_tk_123', 'profile': _profileJson()},
    };
  }

  @override
  Future<Map<String, dynamic>> getJson(
    Uri uri, {
    Map<String, String>? headers,
  }) async {
    if (getError != null) throw getError!;
    lastGetUri = uri;
    lastGetHeaders = headers;
    return {'status': 'success', 'data': _profileJson()};
  }

  static Map<String, dynamic> _profileJson() => {
        'id': 'user-1',
        'kycVerified': true,
        'kycAnchorHash': null,
        'wallet': {
          'address': '0x123',
          'tnsName': 'alice',
          'network': 'testnet'
        },
      };
}

Future<T> _waitFor<T extends Object>(T? Function() read) async {
  for (var i = 0; i < 10; i++) {
    final value = read();
    if (value != null) return value;
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  throw StateError('Timed out waiting for value.');
}
