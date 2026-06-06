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
      expect(config.scopes, ToroPassClientConfig.defaultScopes);
      expect(config.scopeValues, ['kyc_status', 'wallet']);
      expect(config.callbackTimeout, const Duration(minutes: 2));
    });

    test('allows custom scopes and issuer base URL', () {
      final config = ToroPassClientConfig(
        clientId: 'toro_client_123',
        redirectUri: Uri.parse('myapp://callback'),
        issuerBaseUrl: Uri.parse('http://localhost:3000/api/v1'),
        scopes: {ToroPassScope.kycStatus},
      );

      expect(config.issuerBaseUrl.toString(), 'http://localhost:3000/api/v1');
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
}
