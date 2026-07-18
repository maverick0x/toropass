import 'package:equatable/equatable.dart';

class OAuthPermissionRequestEntity extends Equatable {
  static const supportedScopes = {'kyc_status', 'wallet'};
  static final _codeChallengePattern = RegExp(r'^[A-Za-z0-9_-]{43}$');

  final String clientId;
  final String redirectUri;
  final String appName;
  final String? state;
  final List<String> scopes;
  final String codeChallenge;
  final String codeChallengeMethod;

  const OAuthPermissionRequestEntity({
    required this.clientId,
    required this.redirectUri,
    required this.appName,
    required this.codeChallenge,
    required this.codeChallengeMethod,
    this.state,
    this.scopes = const [],
  });

  bool get isValid =>
      clientId.trim().isNotEmpty &&
      redirectUri.trim().isNotEmpty &&
      scopes.isNotEmpty &&
      scopes.every(supportedScopes.contains) &&
      _codeChallengePattern.hasMatch(codeChallenge) &&
      codeChallengeMethod == 'S256';

  @override
  List<Object?> get props => [
    clientId,
    redirectUri,
    appName,
    state,
    scopes,
    codeChallenge,
    codeChallengeMethod,
  ];
}
