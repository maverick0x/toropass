import '../../../../core/config/resource/data_state.dart';
import '../../../../core/config/resource/response.dart';
import '../../domain/entities/profile_entity.dart';

class UserStateModel {
  final String username;
  final String privateKey;
  final DataState<ProfileEntity> walletState;
  final DataState<SuccessResponse> changePasswordState;

  UserStateModel({
    this.username = '',
    this.privateKey = '',
    this.walletState = const DataInitial(),
    this.changePasswordState = const DataInitial(),
  });

  UserStateModel copyWith({
    String? username,
    String? privateKey,
    DataState<ProfileEntity>? walletState,
    DataState<SuccessResponse>? changePasswordState,
  }) {
    return UserStateModel(
      username: username ?? this.username,
      privateKey: privateKey ?? this.privateKey,
      walletState: walletState ?? this.walletState,
      changePasswordState: changePasswordState ?? this.changePasswordState,
    );
  }
}
