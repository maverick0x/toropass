import '../../../../core/config/resource/data_state.dart';
import '../../../../core/config/resource/response.dart';
import '../../domain/entities/consent_entity.dart';
import '../../domain/entities/profile_entity.dart';

class UserStateModel {
  final String username;
  final String privateKey;
  final DataState<ProfileEntity> walletState;
  final DataState<List<ConsentEntity>> consentState;
  final DataState<SuccessResponse> revokeConsentState;
  final DataState<SuccessResponse> changePasswordState;

  UserStateModel({
    this.username = '',
    this.privateKey = '',
    this.walletState = const DataInitial(),
    this.consentState = const DataInitial(),
    this.revokeConsentState = const DataInitial(),
    this.changePasswordState = const DataInitial(),
  });

  UserStateModel copyWith({
    String? username,
    String? privateKey,
    DataState<ProfileEntity>? walletState,
    DataState<List<ConsentEntity>>? consentState,
    DataState<SuccessResponse>? revokeConsentState,
    DataState<SuccessResponse>? changePasswordState,
  }) {
    return UserStateModel(
      username: username ?? this.username,
      privateKey: privateKey ?? this.privateKey,
      walletState: walletState ?? this.walletState,
      consentState: consentState ?? this.consentState,
      revokeConsentState: revokeConsentState ?? this.revokeConsentState,
      changePasswordState: changePasswordState ?? this.changePasswordState,
    );
  }
}
