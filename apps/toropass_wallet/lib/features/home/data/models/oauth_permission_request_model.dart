import '../../domain/entities/oauth_permission_request_entity.dart';

class OAuthPermissionRequestModel extends OAuthPermissionRequestEntity {
  const OAuthPermissionRequestModel({
    required super.clientId,
    required super.redirectUri,
    required super.appName,
    required super.codeChallenge,
    required super.codeChallengeMethod,
    super.state,
    super.scopes,
  });

  factory OAuthPermissionRequestModel.fromUri(Uri uri) {
    final query = uri.queryParameters;
    final rawScopes = [
      ...uri.queryParametersAll['scopes'] ?? const <String>[],
      ...uri.queryParametersAll['scope'] ?? const <String>[],
      if (query['scopes'] != null) query['scopes']!,
      if (query['scope'] != null) query['scope']!,
    ];

    final scopes = rawScopes
        .expand((value) => value.split(','))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList();

    return OAuthPermissionRequestModel(
      clientId: query['client_id']?.trim() ?? '',
      redirectUri: query['redirect_uri']?.trim() ?? '',
      appName:
          query['app_name']?.trim() ??
          query['name']?.trim() ??
          query['client_id']?.trim() ??
          'Connected App',
      state: query['state']?.trim(),
      scopes: scopes,
      codeChallenge: query['code_challenge']?.trim() ?? '',
      codeChallengeMethod: query['code_challenge_method']?.trim() ?? '',
    );
  }
}
