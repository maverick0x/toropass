import '../../domain/entities/oauth_authorize_result_entity.dart';

class OAuthAuthorizeResultModel extends OAuthAuthorizeResultEntity {
  const OAuthAuthorizeResultModel({super.code});

  factory OAuthAuthorizeResultModel.fromJson(Map<String, dynamic> json) {
    return OAuthAuthorizeResultModel(
      code: json['code']?.toString(),
    );
  }
}
