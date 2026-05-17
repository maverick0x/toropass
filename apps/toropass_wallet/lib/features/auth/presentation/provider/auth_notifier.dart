import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/token/token_model.dart';
import '../../../../core/network/token/token_notifier.dart';
import '../../data/model/auth_state_model.dart';

part 'auth_notifier.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthStateModel build() => AuthStateModel();

  void changeUsername(String? username) {
    state = state.copyWith(username: username);
  }

  void changePassword(String? password) {
    state = state.copyWith(password: password);
  }

  void changePrivateKey(String? privateKey) {
    state = state.copyWith(privateKey: privateKey);
  }

  void login() => ref
      .read(tokenProvider.notifier)
      .updateTokens(
        TokenModel(accessToken: "accessToken", refreshToken: "refreshToken"),
      );
}
