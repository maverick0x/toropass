import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/config/resource/data_state.dart';
import '../../../../core/config/resource/response.dart';
import '../../../../core/providers/loading_notifier.dart';
import '../../../../core/services/snackbar_service.dart';
import '../../../../core/utilities/logger.dart';
import '../../data/models/developer_state_model.dart';
import '../../domain/entities/developer_app_entity.dart';
import '../../domain/params/register_oauth_app_params.dart';
import '../../domain/usecase/delete_oauth_app_usecase.dart';
import '../../domain/usecase/get_oauth_apps_usecase.dart';
import '../../domain/usecase/register_oauth_app_usecase.dart';
import '../validator/developer_validator.dart';

part 'developer_notifier.g.dart';

@riverpod
class DeveloperNotifier extends _$DeveloperNotifier {
  @override
  DeveloperStateModel build() => DeveloperStateModel();

  void showCreateForm() {
    state = state.copyWith(isCreating: true);
  }

  void hideCreateForm() {
    state = state.copyWith(
      isCreating: false,
      clearNameError: true,
      clearRedirectUriError: true,
    );
  }

  void clearNameError() {
    if (state.nameError == null) return;
    state = state.copyWith(clearNameError: true);
  }

  void clearRedirectUriError() {
    if (state.redirectUriError == null) return;
    state = state.copyWith(clearRedirectUriError: true);
  }

  void dismissLatestCreatedApp() {
    state = state.copyWith(clearLatestCreatedApp: true);
  }

  Future<void> getApps({bool silentError = false}) async {
    final snackbar = ref.read(snackbarProvider);
    final useCase = ref.read(getOAuthAppsUseCaseProvider);

    state = state.copyWith(appsState: const DataLoading());
    final response = await useCase(null);
    state = state.copyWith(appsState: response);

    if (state.appsState is DataFailed) {
      final failedState = state.appsState as DataFailed;
      if (!silentError) {
        final message =
            failedState.error ??
            "An error occurred while loading your applications.";
        AppLogger.log(
          message,
          trace: failedState.trace,
          name: "DEVELOPERNOTIFIER",
        );
        snackbar.display(message: message);
      }
    }
  }

  Future<bool> registerApp({
    required String name,
    required String redirectUri,
  }) async {
    final snackbar = ref.read(snackbarProvider);
    final useCase = ref.read(registerOAuthAppUseCaseProvider);

    state = state.copyWith(
      nameError: DeveloperValidator.validateName(name),
      redirectUriError: DeveloperValidator.validateRedirectUri(redirectUri),
    );

    if (state.nameError != null || state.redirectUriError != null) {
      return false;
    }

    bool success = false;

    await ref.read(loadingProvider.notifier).wrap(() async {
      state = state.copyWith(registerAppState: const DataLoading());
      final response = await useCase(
        RegisterOAuthAppParams(
          name: name.trim(),
          redirectUri: redirectUri.trim(),
        ),
      );

      if (response is DataSuccess) {
        final app = response.data;
        state = state.copyWith(
          registerAppState: response,
          latestCreatedApp: app,
          isCreating: false,
          clearNameError: true,
          clearRedirectUriError: true,
        );
        await getApps(silentError: true);
        success = true;
        return;
      }

      state = state.copyWith(registerAppState: response);
      if (response is DataFailed<DeveloperAppEntity>) {
        final message =
            response.error ??
            "An error occurred while generating application keys.";
        AppLogger.log(
          message,
          trace: response.trace,
          name: "DEVELOPERNOTIFIER",
        );
        snackbar.display(message: message);
      }
    });

    return success;
  }

  Future<void> deleteApp(String appId) async {
    final snackbar = ref.read(snackbarProvider);
    final useCase = ref.read(deleteOAuthAppUseCaseProvider);

    await ref.read(loadingProvider.notifier).wrap(() async {
      state = state.copyWith(deleteAppState: const DataLoading());
      final response = await useCase(appId);
      state = state.copyWith(deleteAppState: response);

      if (response is DataSuccess) {
        snackbar.display(
          message:
              response.data?.message ?? "Application successfully deleted.",
        );
        await getApps(silentError: true);
        return;
      }

      if (response is DataFailed<SuccessResponse>) {
        final message =
            response.error ??
            "An error occurred while deleting the application.";
        AppLogger.log(
          message,
          trace: response.trace,
          name: "DEVELOPERNOTIFIER",
        );
        snackbar.display(message: message);
      }
    });
  }
}
