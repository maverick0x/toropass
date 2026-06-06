import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/config/resource/data_state.dart';
import '../../../../core/providers/loading_notifier.dart';
import '../../../../core/services/snackbar_service.dart';
import '../../../../core/utilities/logger.dart';
import '../../data/models/kyc_state_model.dart';
import '../../domain/params/verify_kyc_params.dart';
import '../../domain/usecase/verify_kyc_usecase.dart';
import '../validator/kyc_validator.dart';
import 'user_notifier.dart';

part 'kyc_notifier.g.dart';

@riverpod
class KycNotifier extends _$KycNotifier {
  @override
  KycStateModel build() => KycStateModel();

  void clearFirstNameError() {
    if (state.firstNameError == null) return;
    state = state.copyWith(clearFirstNameError: true);
  }

  void clearLastNameError() {
    if (state.lastNameError == null) return;
    state = state.copyWith(clearLastNameError: true);
  }

  void clearBvnError() {
    if (state.bvnError == null) return;
    state = state.copyWith(clearBvnError: true);
  }

  void clearPhoneNumberError() {
    if (state.phoneNumberError == null) return;
    state = state.copyWith(clearPhoneNumberError: true);
  }

  void clearDobError() {
    if (state.dobError == null) return;
    state = state.copyWith(clearDobError: true);
  }

  Future<bool> submitKyc({
    required String firstName,
    required String middleName,
    required String lastName,
    required String bvn,
    required String phoneNumber,
    required String dob,
  }) async {
    final snackbar = ref.read(snackbarProvider);
    final useCase = ref.read(verifyKycUseCaseProvider);
    final walletAddress = ref
        .read(userProvider)
        .walletState
        .data
        ?.wallet
        ?.address;
    final formattedDob = KycValidator.formatDob(dob);

    state = state.copyWith(
      firstNameError: KycValidator.validateFirstName(firstName),
      lastNameError: KycValidator.validateLastName(lastName),
      bvnError: KycValidator.validateBvn(bvn),
      phoneNumberError: KycValidator.validatePhoneNumber(phoneNumber),
      dobError: KycValidator.validateDob(dob),
    );

    if (state.hasValidationErrors) {
      return false;
    }

    if (walletAddress == null ||
        walletAddress.isEmpty ||
        formattedDob == null) {
      snackbar.display(
        message: "Wallet address is unavailable. Refresh and try again.",
      );
      return false;
    }

    await ref.read(loadingProvider.notifier).wrap(() async {
      state = state.copyWith(verifyKycState: const DataLoading());
      final response = await useCase(
        VerifyKycParams(
          firstName: firstName.trim(),
          middleName: middleName.trim(),
          lastName: lastName.trim(),
          bvn: bvn.trim(),
          currency: "NGN",
          phoneNumber: KycValidator.formatPhoneNumberForApi(phoneNumber),
          dob: formattedDob,
        ),
      );
      state = state.copyWith(verifyKycState: response);
    });

    if (state.verifyKycState is DataFailed) {
      final failedState = state.verifyKycState as DataFailed;
      final message =
          failedState.error ?? "An error occurred while verifying identity.";
      AppLogger.log(message, trace: failedState.trace, name: "KYCNOTIFIER");
      snackbar.display(message: message);
      return false;
    }

    if (state.verifyKycState is DataSuccess) {
      await ref.read(userProvider.notifier).getWallet();
      return true;
    }

    return false;
  }
}
