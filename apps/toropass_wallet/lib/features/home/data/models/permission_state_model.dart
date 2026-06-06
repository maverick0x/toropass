import '../../../../core/config/resource/data_state.dart';
import '../../domain/entities/oauth_authorize_result_entity.dart';

class PermissionStateModel {
  final DataState<OAuthAuthorizeResultEntity> authorizeState;
  final String? callbackUri;

  PermissionStateModel({
    this.authorizeState = const DataInitial(),
    this.callbackUri,
  });

  PermissionStateModel copyWith({
    DataState<OAuthAuthorizeResultEntity>? authorizeState,
    String? callbackUri,
    bool clearCallbackUri = false,
  }) {
    return PermissionStateModel(
      authorizeState: authorizeState ?? this.authorizeState,
      callbackUri: clearCallbackUri ? null : callbackUri ?? this.callbackUri,
    );
  }
}
