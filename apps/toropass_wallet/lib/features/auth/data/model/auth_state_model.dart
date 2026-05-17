class AuthStateModel {
  final String username;
  final String privateKey;
  final String password;

  AuthStateModel({
    this.username = '',
    this.privateKey = '',
    this.password = '',
  });

  AuthStateModel copyWith({
    String? username,
    String? privateKey,
    String? password,
  }) {
    return AuthStateModel(
      username: username ?? this.username,
      privateKey: privateKey ?? this.privateKey,
      password: password ?? this.password,
    );
  }
}
