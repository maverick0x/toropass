class UserStateModel {
  final String username;
  final String privateKey;

  UserStateModel({this.username = '', this.privateKey = ''});

  UserStateModel copyWith({String? username, String? privateKey}) {
    return UserStateModel(
      username: username ?? this.username,
      privateKey: privateKey ?? this.privateKey,
    );
  }
}
