import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

final localAuthProvider = Provider((ref) => LocalAuthentication());
final biometricServiceProvider = Provider(
  (ref) => BiometricService(localAuthentication: ref.read(localAuthProvider)),
);
final biometricLabelProvider = FutureProvider<String>((ref) async {
  final service = ref.read(biometricServiceProvider);
  final isAvailable = await service.isBiometricAvailable();

  if (isAvailable) {
    return service.biometricTypeLabel;
  }
  return "";
});

class BiometricService {
  final LocalAuthentication localAuthentication;
  String biometricTypeLabel = '';
  bool _isAuthenticating = false;
  bool _skipNextResumePrompt = false;

  BiometricService({required this.localAuthentication});

  bool get isAuthenticating => _isAuthenticating;

  bool consumeSkipNextResumePrompt() {
    if (!_skipNextResumePrompt) return false;
    _skipNextResumePrompt = false;
    return true;
  }

  Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics =
          await localAuthentication.canCheckBiometrics;
      final bool isDeviceSupported = await localAuthentication
          .isDeviceSupported();

      if (canAuthenticateWithBiometrics && isDeviceSupported) {
        return _updateBiometricLabel(); // Update the label based on available biometrics
      }

      return false;
    } on PlatformException catch (_) {
      return false;
    }
  }

  Future<bool> _updateBiometricLabel() async {
    final List<BiometricType> availableBiometrics = await localAuthentication
        .getAvailableBiometrics();

    if (availableBiometrics.contains(BiometricType.face)) {
      biometricTypeLabel = "Face ID";
      return true;
    } else if (availableBiometrics.contains(BiometricType.fingerprint) ||
        availableBiometrics.contains(BiometricType.strong)) {
      biometricTypeLabel = "Fingerprint";
      return true;
    } else {
      biometricTypeLabel = "Biometrics";
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      _isAuthenticating = true;
      _skipNextResumePrompt = true;
      final label = biometricTypeLabel == 'Face ID'
          ? "Scan your face"
          : 'Scan your fingerprint';

      return await localAuthentication.authenticate(
        localizedReason: label,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
        authMessages: [
          IOSAuthMessages(cancelButton: 'Cancel'),
          AndroidAuthMessages(cancelButton: 'Cancel'),
        ],
      );
    } on PlatformException catch (_) {
      return false;
    } on LocalAuthException catch (_) {
      return false;
    } finally {
      _isAuthenticating = false;
    }
  }

  Future<void> cancelAuthentication() async {
    await localAuthentication.stopAuthentication();
  }
}
