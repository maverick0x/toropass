class TokenModel {
  TokenModel({this.accessToken, this.refreshToken});

  final String? accessToken;
  final String? refreshToken;

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
