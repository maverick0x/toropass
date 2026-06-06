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

  final String clientId;
  final Uri redirectUri;
  final Set<ToroPassScope> scopes;
  final Uri issuerBaseUrl;
  final Uri walletLaunchUri;
  final Duration callbackTimeout;

  ToroPassClientConfig({
    required String clientId,
    required Uri redirectUri,
    Set<ToroPassScope> scopes = defaultScopes,
    Uri? issuerBaseUrl,
    Uri? walletLaunchUri,
    Duration callbackTimeout = const Duration(minutes: 2),
  }) : clientId = _requireClientId(clientId),
       redirectUri = _requireAbsoluteUri(redirectUri, 'redirectUri'),
       scopes = _requireScopes(scopes),
       issuerBaseUrl = _requireAbsoluteUri(
         issuerBaseUrl ?? defaultIssuerBaseUrl,
         'issuerBaseUrl',
       ),
       walletLaunchUri = _requireAbsoluteUri(
         walletLaunchUri ?? defaultWalletLaunchUri,
         'walletLaunchUri',
       ),
       callbackTimeout = _requirePositiveDuration(
         callbackTimeout,
         'callbackTimeout',
       );

  List<String> get scopeValues => scopes.map((scope) => scope.value).toList();

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
