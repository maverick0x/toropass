import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/keys.dart';
import '../../../../core/config/resource/data_state.dart';
import '../../../../core/providers/loading_notifier.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../core/services/snackbar_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/utilities/logger.dart';
import '../../data/models/settings_state_model.dart';
import '../../domain/params/change_password_params.dart';
import '../../domain/usecase/change_password_usecase.dart';
import '../validator/change_password_validator.dart';

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsStateModel>(
  SettingsNotifier.new,
);

class SettingsNotifier extends Notifier<SettingsStateModel> {
  @override
  SettingsStateModel build() => const SettingsStateModel();

  Future<void> loadSettings() async {
    if (state.loaded) return;

    final storage = ref.read(storageServiceProvider);
    final biometricService = ref.read(biometricServiceProvider);
    final biometricsAvailable = await biometricService.isBiometricAvailable();
    final biometricsEnabled =
        storage.getDataFromDisk(AppKeys.biometricsEnabled) as bool? ?? false;

    state = state.copyWith(
      loaded: true,
      biometricsAvailable: biometricsAvailable,
      biometricsEnabled: biometricsAvailable && biometricsEnabled,
      biometricLabel: biometricService.biometricTypeLabel.isEmpty
          ? 'Biometrics'
          : biometricService.biometricTypeLabel,
    );
  }

  Future<void> toggleBiometrics(bool enabled) async {
    if (!state.biometricsAvailable) return;

    final storage = ref.read(storageServiceProvider);
    await storage.saveDataToDisk(AppKeys.biometricsEnabled, enabled);
    state = state.copyWith(biometricsEnabled: enabled);
  }

  void clearCurrentPasswordError() {
    if (state.currentPasswordError.isEmpty) return;
    state = state.copyWith(currentPasswordError: '');
  }

  void clearNewPasswordError() {
    if (state.newPasswordError.isEmpty) return;
    state = state.copyWith(newPasswordError: '');
  }

  void clearConfirmPasswordError() {
    if (state.confirmPasswordError.isEmpty) return;
    state = state.copyWith(confirmPasswordError: '');
  }

  Future<bool> submitChangePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final currentPasswordError =
        ChangePasswordValidator.validateCurrentPassword(currentPassword);
    final newPasswordError = ChangePasswordValidator.validateNewPassword(
      newPassword,
    );
    final confirmPasswordError =
        ChangePasswordValidator.validateConfirmPassword(
          newPassword,
          confirmPassword,
        );

    state = state.copyWith(
      currentPasswordError: currentPasswordError ?? '',
      newPasswordError: newPasswordError ?? '',
      confirmPasswordError: confirmPasswordError ?? '',
    );

    final isValid =
        currentPasswordError == null &&
        newPasswordError == null &&
        confirmPasswordError == null;
    if (!isValid) return false;

    final snackbar = ref.read(snackbarProvider);
    final useCase = ref.read(changePasswordUseCaseProvider);
    final params = ChangePasswordParams(
      oldPassword: currentPassword,
      newPassword: newPassword,
    );

    await ref.read(loadingProvider.notifier).wrap(() async {
      state = state.copyWith(changePasswordState: const DataLoading());
      final response = await useCase(params);
      state = state.copyWith(changePasswordState: response);
    });

    if (state.changePasswordState is DataFailed) {
      final failedState = state.changePasswordState as DataFailed;
      final message =
          failedState.error ?? 'An error occurred while changing the password.';
      AppLogger.log(message, trace: failedState.trace, name: 'SETTINGS');
      snackbar.display(message: message);
      return false;
    }

    final message =
        state.changePasswordState.data?.message ??
        'Password changed successfully.';
    snackbar.display(message: message);
    return true;
  }
}
