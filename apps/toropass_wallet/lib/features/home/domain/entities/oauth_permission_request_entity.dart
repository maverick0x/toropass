import 'package:equatable/equatable.dart';

class OAuthPermissionRequestEntity extends Equatable {
  final String clientId;
  final String redirectUri;
  final String appName;
  final String? state;
  final List<String> scopes;

  const OAuthPermissionRequestEntity({
    required this.clientId,
    required this.redirectUri,
    required this.appName,
    this.state,
    this.scopes = const [],
  });

  bool get isValid =>
      clientId.trim().isNotEmpty &&
      redirectUri.trim().isNotEmpty &&
      scopes.isNotEmpty;

  @override
  List<Object?> get props => [clientId, redirectUri, appName, state, scopes];
}
