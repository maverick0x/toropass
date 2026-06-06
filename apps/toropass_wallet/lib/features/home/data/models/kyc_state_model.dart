import '../../../../core/config/resource/data_state.dart';
import '../../../../core/config/resource/response.dart';

class KycStateModel {
  final String? firstNameError;
  final String? lastNameError;
  final String? bvnError;
  final String? phoneNumberError;
  final String? dobError;
  final DataState<SuccessResponse> verifyKycState;

  KycStateModel({
    this.firstNameError,
    this.lastNameError,
    this.bvnError,
    this.phoneNumberError,
    this.dobError,
    this.verifyKycState = const DataInitial(),
  });

  bool get hasValidationErrors =>
      firstNameError != null ||
      lastNameError != null ||
      bvnError != null ||
      phoneNumberError != null ||
      dobError != null;

  KycStateModel copyWith({
    String? firstNameError,
    bool clearFirstNameError = false,
    String? lastNameError,
    bool clearLastNameError = false,
    String? bvnError,
    bool clearBvnError = false,
    bool clearCurrencyError = false,
    String? phoneNumberError,
    bool clearPhoneNumberError = false,
    String? dobError,
    bool clearDobError = false,
    DataState<SuccessResponse>? verifyKycState,
  }) {
    return KycStateModel(
      firstNameError: clearFirstNameError
          ? null
          : firstNameError ?? this.firstNameError,
      lastNameError: clearLastNameError
          ? null
          : lastNameError ?? this.lastNameError,
      bvnError: clearBvnError ? null : bvnError ?? this.bvnError,
      phoneNumberError: clearPhoneNumberError
          ? null
          : phoneNumberError ?? this.phoneNumberError,
      dobError: clearDobError ? null : dobError ?? this.dobError,
      verifyKycState: verifyKycState ?? this.verifyKycState,
    );
  }
}
