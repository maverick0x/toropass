import 'package:equatable/equatable.dart';

class OAuthPermissionRequestEntity extends Equatable {
  final String clientId;
  final String redirectUri;
  final String appName;
  final List<String> scopes;

  const OAuthPermissionRequestEntity({
    required this.clientId,
    required this.redirectUri,
    required this.appName,
    this.scopes = const [],
  });

  bool get isValid =>
      clientId.trim().isNotEmpty &&
      redirectUri.trim().isNotEmpty &&
      scopes.isNotEmpty;

  @override
  List<Object?> get props => [clientId, redirectUri, appName, scopes];
}
