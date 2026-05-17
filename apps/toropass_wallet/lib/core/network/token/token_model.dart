class TokenModel {
  TokenModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
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

  Map<String, dynamic> toJson() => {
    "accessToken": accessToken,
    "refreshToken": refreshToken,
    "user": user?.toJson(),
  };
}

class TokenUser {
  TokenUser({
    required this.id,
    this.name,
    this.email,
    this.userType,
    this.accountType,
    this.profileStatus,
    this.kycStatus,
    this.isEmailVerified,
    this.isActive,
  });

  final String? id;
  final String? name;
  final String? email;
  final String? userType;
  final String? accountType;
  final String? profileStatus;
  final String? kycStatus;
  final bool? isEmailVerified;
  final bool? isActive;

  TokenUser copyWith({
    String? id,
    String? name,
    String? email,
    String? userType,
    String? accountType,
    String? profileStatus,
    String? kycStatus,
    bool? isEmailVerified,
    bool? isActive,
  }) {
    return TokenUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      accountType: accountType ?? this.accountType,
      profileStatus: profileStatus ?? this.profileStatus,
      kycStatus: kycStatus ?? this.kycStatus,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isActive: isActive ?? this.isActive,
    );
  }

  factory TokenUser.fromJson(Map<String, dynamic> json) {
    return TokenUser(
      id: json["id"],
      name: json["name"],
      email: json["email"],
      userType: json["userType"],
      accountType: json["accountType"],
      profileStatus: json["profileStatus"],
      kycStatus: json["kycStatus"],
      isEmailVerified: json["isEmailVerified"],
      isActive: json["isActive"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "userType": userType,
    "accountType": accountType,
    "profileStatus": profileStatus,
    "kycStatus": kycStatus,
    "isEmailVerified": isEmailVerified,
    "isActive": isActive,
  };
}
