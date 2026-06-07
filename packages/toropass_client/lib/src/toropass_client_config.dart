import 'toropass_scope.dart';

class ToroPassClientConfig {
  static final Uri defaultIssuerBaseUrl = Uri.parse(
    'https://api.toropass.app/api/v1',
  );

  static final Uri defaultWalletLaunchUri = Uri(
    scheme: 'toropass',
    path: '/permission',
  );

  static const Set<ToroPassScope> defaultScopes = {
    ToroPassScope.kycStatus,
    ToroPassScope.wallet,
  };

  final String appName;
  final String clientId;
  final Uri redirectUri;
  final Set<ToroPassScope> scopes;
  final Uri issuerBaseUrl;
  final Uri walletLaunchUri;
  final Duration callbackTimeout;

  ToroPassClientConfig({
    required String appName,
    required String clientId,
    required Uri redirectUri,
    Set<ToroPassScope> scopes = defaultScopes,
    Duration callbackTimeout = const Duration(minutes: 2),
  })  : appName = _requireAppName(appName),
        clientId = _requireClientId(clientId),
        redirectUri = _requireAbsoluteUri(redirectUri, 'redirectUri'),
        scopes = _requireScopes(scopes),
        issuerBaseUrl = _requireAbsoluteUri(
          defaultIssuerBaseUrl,
          'issuerBaseUrl',
        ),
        walletLaunchUri = _requireAbsoluteUri(
          defaultWalletLaunchUri,
          'walletLaunchUri',
        ),
        callbackTimeout = _requirePositiveDuration(
          callbackTimeout,
          'callbackTimeout',
        );

  List<String> get scopeValues => scopes.map((scope) => scope.value).toList();

  static String _requireAppName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(value, 'appName', 'App name is required.');
    }
    return trimmed;
  }

  static String _requireClientId(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(value, 'clientId', 'Client ID is required.');
    }
    return trimmed;
  }

  static Uri _requireAbsoluteUri(Uri value, String name) {
    if (!value.hasScheme) {
      throw ArgumentError.value(value, name, 'URI must include a scheme.');
    }
    return value;
  }

  static Set<ToroPassScope> _requireScopes(Set<ToroPassScope> value) {
    if (value.isEmpty) {
      throw ArgumentError.value(
        value,
        'scopes',
        'At least one scope is required.',
      );
    }
    return Set.unmodifiable(value);
  }

  static Duration _requirePositiveDuration(Duration value, String name) {
    if (value <= Duration.zero) {
      throw ArgumentError.value(value, name, 'Duration must be positive.');
    }
    return value;
  }
}
