import '../../../../core/config/resource/data_state.dart';
import '../../../../core/config/resource/response.dart';
import '../../domain/entities/developer_app_entity.dart';

class DeveloperStateModel {
  final bool isCreating;
  final String? nameError;
  final String? redirectUriError;
  final DeveloperAppEntity? latestCreatedApp;
  final DataState<List<DeveloperAppEntity>> appsState;
  final DataState<DeveloperAppEntity> registerAppState;
  final DataState<SuccessResponse> deleteAppState;

  DeveloperStateModel({
    this.isCreating = false,
    this.nameError,
    this.redirectUriError,
    this.latestCreatedApp,
    this.appsState = const DataInitial(),
    this.registerAppState = const DataInitial(),
    this.deleteAppState = const DataInitial(),
  });

  DeveloperStateModel copyWith({
    bool? isCreating,
    String? nameError,
    bool clearNameError = false,
    String? redirectUriError,
    bool clearRedirectUriError = false,
    DeveloperAppEntity? latestCreatedApp,
    bool clearLatestCreatedApp = false,
    DataState<List<DeveloperAppEntity>>? appsState,
    DataState<DeveloperAppEntity>? registerAppState,
    DataState<SuccessResponse>? deleteAppState,
  }) {
    return DeveloperStateModel(
      isCreating: isCreating ?? this.isCreating,
      nameError: clearNameError ? null : nameError ?? this.nameError,
      redirectUriError: clearRedirectUriError
          ? null
          : redirectUriError ?? this.redirectUriError,
      latestCreatedApp: clearLatestCreatedApp
          ? null
          : latestCreatedApp ?? this.latestCreatedApp,
      appsState: appsState ?? this.appsState,
      registerAppState: registerAppState ?? this.registerAppState,
      deleteAppState: deleteAppState ?? this.deleteAppState,
    );
  }
}
