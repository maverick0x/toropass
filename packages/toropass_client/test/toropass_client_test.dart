import 'package:flutter_test/flutter_test.dart';
import 'package:toropass_client/toropass_client.dart';

void main() {
  group('ToroPassClientConfig', () {
    test('sets safe defaults for issuer, scopes, and timeout', () {
      final config = ToroPassClientConfig(
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

    test('allows custom scopes and issuer base URL', () {
      final config = ToroPassClientConfig(
        clientId: 'toro_client_123',
        redirectUri: Uri.parse('myapp://callback'),
        issuerBaseUrl: Uri.parse('http://localhost:3000/api/v1'),
        walletLaunchUri: Uri.parse('toropass-dev:///permission'),
        scopes: {ToroPassScope.kycStatus},
      );

      expect(config.issuerBaseUrl.toString(), 'http://localhost:3000/api/v1');
      expect(config.walletLaunchUri.toString(), 'toropass-dev:///permission');
      expect(config.scopeValues, ['kyc_status']);
    });

    test('rejects incomplete config', () {
      expect(
        () => ToroPassClientConfig(
          clientId: '',
          redirectUri: Uri.parse('myapp://callback'),
        ),
        throwsArgumentError,
      );

      expect(
        () => ToroPassClientConfig(
          clientId: 'toro_client_123',
          redirectUri: Uri.parse('/callback'),
        ),
        throwsArgumentError,
      );

      expect(
        () => ToroPassClientConfig(
          clientId: 'toro_client_123',
          redirectUri: Uri.parse('myapp://callback'),
          scopes: const {},
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
  });

  group('ToroPass wallet launch transport', () {
    test('builds a wallet permission URI with OAuth query parameters', () {
      final client = ToroPassClient(
        config: ToroPassClientConfig(
          clientId: 'toro_client_123',
          redirectUri: Uri.parse('myapp://toropass/callback'),
        ),
      );

      final request = client.createAuthorizationRequest(
        appName: 'Example App',
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
