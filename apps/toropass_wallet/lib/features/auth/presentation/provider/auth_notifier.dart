import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/config/resource/data_state.dart';
import '../../../../core/network/token/token_entity.dart';
import '../../../../core/network/token/token_notifier.dart';
import '../../../../core/providers/loading_notifier.dart';
import '../../../../core/services/snackbar_service.dart';
import '../../../../core/utilities/logger.dart';
import '../../data/models/auth_state_model.dart';
import '../../domain/entities/tns_entity.dart';
import '../../domain/params/wallet_params.dart';
import '../../domain/usecase/check_tns_name_usecase.dart';
import '../../domain/usecase/create_wallet_usecase.dart';
import '../../domain/usecase/validate_wallet_usecase.dart';
import '../validator/auth_validator.dart';

part 'auth_notifier.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  Timer? _debounceTimer;

  @override
  AuthStateModel build() {
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });
    return AuthStateModel();
  }

  void changeUsername(String? username) {
    state = state.copyWith(
      username: username,
      tnsState: const DataInitial(),
      createWalletState: const DataInitial(),
      validateWalletState: const DataInitial(),
    );
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      checkTNSName();
    });
  }

  bool get isNewUser =>
      state.tnsState is DataSuccess &&
      (state.tnsState as DataSuccess).data?.isAvailable == true;

  void changePassword(String? password) {
    state = state.copyWith(password: password);
  }

  void changePrivateKey(String? privateKey) {
    state = state.copyWith(privateKey: privateKey);
  }

  Future<void> submit() async {
    final snackbar = ref.read(snackbarProvider);
    final username = state.username.trim();

    final usernameError = AuthValidator.validateUsername(username);
    if (usernameError != null) {
      snackbar.display(message: usernameError);
      return;
    }

    final passwordError = AuthValidator.validatePassword(state.password);
    if (passwordError != null) {
      snackbar.display(message: passwordError);
      return;
    }

    if (state.tnsState is DataLoading) return;

    final tnsState = await _ensureFreshTnsState(username);
    if (tnsState == null) return;

    final params = WalletParams(username: username, password: state.password);
    if (tnsState.isAvailable == true) {
      await createWallet(params);
      return;
    }

    if (tnsState.isAvailable == false) {
      await validateWallet(params);
    }
  }

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

  Future createWallet(WalletParams params) async {
    final snackbar = ref.read(snackbarProvider);
    final useCase = ref.read(createWalletUseCaseProvider);

    await ref.read(loadingProvider.notifier).wrap(() async {
      state = state.copyWith(createWalletState: const DataLoading());
      final response = await useCase(params);
      state = state.copyWith(createWalletState: response);
    });

    if (state.createWalletState is DataSuccess) {
      final notifier = ref.read(tokenProvider.notifier);
      await notifier.updateTokens(
        state.createWalletState.data!.tokens ?? TokenEntity(),
      );
    }

    if (state.createWalletState is DataFailed) {
      final failedState = state.createWalletState as DataFailed;
      final message =
          failedState.error ?? "An error occurred while creating the wallet.";
      AppLogger.log(message, trace: failedState.trace, name: "AUTHNOTIFIER");
      snackbar.display(message: message);
    }
  }

  Future validateWallet(WalletParams params) async {
    final snackbar = ref.read(snackbarProvider);
    final useCase = ref.read(validateWalletUseCaseProvider);

    await ref.read(loadingProvider.notifier).wrap(() async {
      state = state.copyWith(validateWalletState: const DataLoading());
      final response = await useCase(params);
      state = state.copyWith(validateWalletState: response);
    });

    if (state.validateWalletState is DataSuccess) {
      final notifier = ref.read(tokenProvider.notifier);
      await notifier.updateTokens(
        state.validateWalletState.data!.tokens ?? TokenEntity(),
      );
    }

    if (state.validateWalletState is DataFailed) {
      final failedState = state.validateWalletState as DataFailed;
      final message =
          failedState.error ?? "An error occurred while validating the wallet.";
      AppLogger.log(message, trace: failedState.trace, name: "AUTHNOTIFIER");
      snackbar.display(message: message);
    }
  }

  Future<TnsEntity?> _ensureFreshTnsState(String username) async {
    final currentState = state.tnsState;
    if (currentState is DataSuccess &&
        currentState.data?.username == username) {
      return currentState.data;
    }

    await checkTNSName();

    final refreshedState = state.tnsState;
    if (refreshedState is DataSuccess &&
        refreshedState.data?.username == username) {
      return refreshedState.data;
    }

    return null;
  }
}
