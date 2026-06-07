import '../../../../core/config/resource/data_state.dart';
import '../../../../core/config/resource/response.dart';

class SettingsStateModel {
  final bool loaded;
  final bool biometricsAvailable;
  final bool biometricsEnabled;
  final String biometricLabel;
  final String currentPasswordError;
  final String newPasswordError;
  final String confirmPasswordError;
  final DataState<SuccessResponse> changePasswordState;

  const SettingsStateModel({
    this.loaded = false,
    this.biometricsAvailable = false,
    this.biometricsEnabled = false,
    this.biometricLabel = 'Biometrics',
    this.currentPasswordError = '',
    this.newPasswordError = '',
    this.confirmPasswordError = '',
    this.changePasswordState = const DataInitial(),
  });

  SettingsStateModel copyWith({
    bool? loaded,
    bool? biometricsAvailable,
    bool? biometricsEnabled,
    String? biometricLabel,
    String? currentPasswordError,
    String? newPasswordError,
    String? confirmPasswordError,
    DataState<SuccessResponse>? changePasswordState,
  }) {
    return SettingsStateModel(
      loaded: loaded ?? this.loaded,
      biometricsAvailable: biometricsAvailable ?? this.biometricsAvailable,
      biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
      biometricLabel: biometricLabel ?? this.biometricLabel,
      currentPasswordError: currentPasswordError ?? this.currentPasswordError,
      newPasswordError: newPasswordError ?? this.newPasswordError,
      confirmPasswordError: confirmPasswordError ?? this.confirmPasswordError,
      changePasswordState: changePasswordState ?? this.changePasswordState,
    );
  }
}
