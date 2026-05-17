const Object _unspecified = Object();

class TokenStateModel {
  final bool ready;
  final String? token;
  final String? refreshToken;

  const TokenStateModel({this.ready = false, this.token, this.refreshToken});

  TokenStateModel copyWith({
    bool? ready,
    Object? token = _unspecified,
    Object? refreshToken = _unspecified,
  }) {
    return TokenStateModel(
      ready: ready ?? this.ready,
      token: token == _unspecified ? this.token : token as String?,
      refreshToken: refreshToken == _unspecified
          ? this.refreshToken
          : refreshToken as String?,
    );
  }
}
