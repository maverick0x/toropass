import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/config/resource/data_state.dart';
import '../../../../core/network/token/token_model.dart';
import '../../../../core/network/token/token_notifier.dart';
import '../../../../core/services/snackbar_service.dart';
import '../../../../core/utilities/logger.dart';
import '../../data/model/auth_state_model.dart';
import '../../domain/usecase/check_tns_name_usecase.dart';
import '../validator/auth_validator.dart';

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

  Future checkTNSName() async {
    final usernameError = AuthValidator.validateUsername(state.username);
    if (usernameError != null) return;

    final snackbar = ref.read(snackbarProvider);
    final useCase = ref.read(checkTNSNameUseCaseProvider);

    state = state.copyWith(tnsState: const DataLoading());
    final response = await useCase(state.username);
    state = state.copyWith(tnsState: response);

    if (state.tnsState is DataFailed) {
      final failedState = state.tnsState as DataFailed;
      final message =
          failedState.error ?? "An error occurred while checking the username.";
      AppLogger.log(message, trace: failedState.trace, name: "AUTHNOTIFIER");
      snackbar.display(message: message);
      return;
    }
  }
}
