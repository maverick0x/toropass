class TokenModel {
  TokenModel({
    required this.accessToken,
    required this.refreshToken,
    this.user,
  });

  final String? accessToken;
  final String? refreshToken;
  final TokenUser? user;

  TokenModel copyWith({
    String? accessToken,
    String? refreshToken,
    TokenUser? user,
  }) {
    return TokenModel(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
    );
  }

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      accessToken: json["accessToken"],
      refreshToken: json["refreshToken"],
      user: json["user"] == null ? null : TokenUser.fromJson(json["user"]),
    );
  }
}

class TokenUser {
  TokenUser({required this.id, this.username});

  final String? id;
  final String? username;

  TokenUser copyWith({String? id, String? username}) {
    return TokenUser(id: id ?? this.id, username: username ?? this.username);
  }

  factory TokenUser.fromJson(Map<String, dynamic> json) {
    return TokenUser(id: json["id"], username: json["username"]);
  }
}
