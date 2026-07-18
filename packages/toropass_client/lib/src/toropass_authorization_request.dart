import 'toropass_scope.dart';

class ToroPassAuthorizationRequest {
  final Uri launchUri;
  final String state;
  final String clientId;
  final Uri redirectUri;
  final Set<ToroPassScope> scopes;
  final String? appName;

  const ToroPassAuthorizationRequest({
    required this.launchUri,
    required this.state,
    required this.clientId,
    required this.redirectUri,
    required this.scopes,
    this.appName,
  });
}
