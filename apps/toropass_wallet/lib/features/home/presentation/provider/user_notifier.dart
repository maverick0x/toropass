import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/user_state_model.dart';

part 'user_notifier.g.dart';

@riverpod
class UserNotifier extends _$UserNotifier {
  @override
  UserStateModel build() => UserStateModel();

  void changeUsername(String? username) {
    state = state.copyWith(username: username);
  }

  void changePrivateKey(String? privateKey) {
    state = state.copyWith(privateKey: privateKey);
  }
}
