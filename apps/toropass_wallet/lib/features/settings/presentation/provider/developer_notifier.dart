import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/config/resource/data_state.dart';
import '../../../../core/providers/loading_notifier.dart';
import '../../../../core/services/snackbar_service.dart';
import '../../../../core/utilities/logger.dart';
import '../../data/models/developer_state_model.dart';
import '../../data/repository/developer_repository_impl.dart';
import '../../domain/params/register_oauth_app_params.dart';
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
    final repo = ref.read(developerRepositoryProvider);

    state = state.copyWith(appsState: const DataLoading());

    try {
      final apps = await repo.getApps();
      state = state.copyWith(appsState: DataSuccess(data: apps));
    } catch (e, st) {
      state = state.copyWith(appsState: DataFailed(error: e.toString(), trace: st));

      if (!silentError) {
        final message = "An error occurred while loading your applications.";
        AppLogger.log(e.toString(), trace: st, name: "DEVELOPERNOTIFIER");
        snackbar.display(message: message);
      }
    }
  }

  Future<bool> registerApp({
    required String name,
    required String redirectUri,
  }) async {
    final snackbar = ref.read(snackbarProvider);
    final repo = ref.read(developerRepositoryProvider);

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

      try {
        final app = await repo.registerApp(
          RegisterOAuthAppParams(
            name: name.trim(),
            redirectUri: redirectUri.trim(),
          ),
        );
        state = state.copyWith(
          registerAppState: const DataSuccess(),
          latestCreatedApp: app,
          isCreating: false,
          clearNameError: true,
          clearRedirectUriError: true,
        );
        await getApps(silentError: true);
        success = true;
      } catch (e, st) {
        state = state.copyWith(
          registerAppState: DataFailed(error: e.toString(), trace: st),
        );
        AppLogger.log(e.toString(), trace: st, name: "DEVELOPERNOTIFIER");
        snackbar.display(
          message: "An error occurred while generating application keys.",
        );
      }
    });

    return success;
  }

  Future<void> deleteApp(String appId) async {
    final snackbar = ref.read(snackbarProvider);
    final repo = ref.read(developerRepositoryProvider);

    await ref.read(loadingProvider.notifier).wrap(() async {
      state = state.copyWith(deleteAppState: const DataLoading());

      try {
        final response = await repo.deleteApp(appId);
        state = state.copyWith(deleteAppState: DataSuccess(data: response));
        snackbar.display(
          message: response.message ?? "Application successfully deleted.",
        );
        await getApps(silentError: true);
      } catch (e, st) {
        state = state.copyWith(
          deleteAppState: DataFailed(error: e.toString(), trace: st),
        );
        AppLogger.log(e.toString(), trace: st, name: "DEVELOPERNOTIFIER");
        snackbar.display(
          message: "An error occurred while deleting the application.",
        );
      }
    });
  }
}
