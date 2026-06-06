import '../entities/oauth_authorize_result_entity.dart';
import '../params/oauth_authorize_params.dart';

abstract class OAuthRepository {
  Future<OAuthAuthorizeResultEntity> authorize(OAuthAuthorizeParams params);
}
