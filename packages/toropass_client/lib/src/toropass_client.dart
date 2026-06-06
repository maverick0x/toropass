import 'toropass_client_config.dart';
import 'toropass_profile.dart';
import 'toropass_result.dart';

class ToroPassClient {
  final ToroPassClientConfig config;

  const ToroPassClient({required this.config});

  Future<ToroPassAuthResult> verifyIdentity() {
    throw UnimplementedError(
      'verifyIdentity will be implemented in the wallet launch and OAuth phases.',
    );
  }

  Future<ToroPassOAuthToken> exchangeAuthorizationCode({required String code}) {
    throw UnimplementedError(
      'exchangeAuthorizationCode will be implemented with /oauth/token.',
    );
  }

  Future<ToroPassProfile> fetchProfile({required String accessToken}) {
    throw UnimplementedError(
      'fetchProfile will be implemented with /oauth/profile.',
    );
  }
}
