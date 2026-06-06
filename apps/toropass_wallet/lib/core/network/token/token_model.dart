import 'token_entity.dart';

class TokenModel extends TokenEntity {
  const TokenModel({super.accessToken, super.refreshToken});

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      accessToken: json["accessToken"],
      refreshToken: json["refreshToken"],
    );
  }

  TokenModel copyWith({String? accessToken, String? refreshToken}) {
    return TokenModel(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}
