import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/config/resource/data_state.dart';
import '../../../../core/providers/loading_notifier.dart';
import '../../../../core/services/snackbar_service.dart';
import '../../../../core/utilities/logger.dart';
import '../../data/models/user_state_model.dart';
import '../../domain/params/change_password_params.dart';
import '../../domain/usecase/change_password_usecase.dart';
import '../../domain/usecase/get_wallet_usecase.dart';

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

  Future getWallet() async {
    final snackbar = ref.read(snackbarProvider);
    final useCase = ref.read(getWalletUseCaseProvider);

    state = state.copyWith(walletState: const DataLoading());
    final response = await useCase(null);
    state = state.copyWith(walletState: response);

    if (state.walletState is DataFailed) {
      final failedState = state.walletState as DataFailed;
      final message =
          failedState.error ?? "An error occurred while fetching wallet data.";
      AppLogger.log(message, trace: failedState.trace, name: "USERNOTIFIER");
      snackbar.display(message: message);
    }
  }

  Future submitChangePassword(ChangePasswordParams params) async {
    final snackbar = ref.read(snackbarProvider);
    final useCase = ref.read(changePasswordUseCaseProvider);

    await ref.read(loadingProvider.notifier).wrap(() async {
      state = state.copyWith(changePasswordState: const DataLoading());
      final response = await useCase(params);
      state = state.copyWith(changePasswordState: response);
    });

    if (state.changePasswordState is DataFailed) {
      final failedState = state.changePasswordState as DataFailed;
      final message =
          failedState.error ?? "An error occurred while changing the password.";
      AppLogger.log(message, trace: failedState.trace, name: "USERNOTIFIER");
      snackbar.display(message: message);
    }
  }
}
