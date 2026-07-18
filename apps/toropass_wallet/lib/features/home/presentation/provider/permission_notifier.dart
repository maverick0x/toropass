import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/config/resource/data_state.dart';
import '../../../../core/providers/loading_notifier.dart';
import '../../../../core/services/snackbar_service.dart';
import '../../../../core/utilities/logger.dart';
import '../../data/models/permission_state_model.dart';
import '../../domain/entities/oauth_permission_request_entity.dart';
import '../../domain/params/oauth_authorize_params.dart';
import '../../domain/usecase/authorize_oauth_usecase.dart';

part 'permission_notifier.g.dart';

@riverpod
class PermissionNotifier extends _$PermissionNotifier {
  @override
  PermissionStateModel build() => PermissionStateModel();

  void reset() {
    state = PermissionStateModel();
  }

  Future<bool> authorize(OAuthPermissionRequestEntity request) async {
    final snackbar = ref.read(snackbarProvider);
    final useCase = ref.read(authorizeOAuthUseCaseProvider);

    if (!request.isValid) {
      snackbar.display(
        message: "This permission request is missing required information.",
      );
      return false;
    }

    await ref.read(loadingProvider.notifier).wrap(() async {
      state = state.copyWith(
        authorizeState: const DataLoading(),
        clearCallbackUri: true,
      );
      final response = await useCase(
        OAuthAuthorizeParams(
          clientId: request.clientId,
          redirectUri: request.redirectUri,
          scopes: request.scopes,
          codeChallenge: request.codeChallenge,
          codeChallengeMethod: request.codeChallengeMethod,
        ),
      );
      state = state.copyWith(authorizeState: response);
    });

    if (state.authorizeState is DataFailed) {
      final failedState = state.authorizeState as DataFailed;
      final message =
          failedState.message ??
          "An error occurred while approving app permissions.";
      AppLogger.log(
        message,
        trace: failedState.trace,
        name: "PERMISSIONNOTIFIER",
      );
      snackbar.display(message: message);
      return false;
    }

    if (state.authorizeState is DataSuccess) {
      final code = state.authorizeState.data?.code;
      if (code == null || code.isEmpty) {
        return false;
      }

      final callbackUri = buildSuccessCallbackUri(
        request.redirectUri,
        code,
        state: request.state,
      );
      state = state.copyWith(callbackUri: callbackUri);
      return true;
    }

    return false;
  }

  String buildSuccessCallbackUri(
    String redirectUri,
    String code, {
    String? state,
  }) {
    final uri = Uri.parse(redirectUri);
    final query = Map<String, String>.from(uri.queryParameters);
    query['code'] = code;
    if (state?.isNotEmpty == true) query['state'] = state!;
    return uri.replace(queryParameters: query).toString();
  }

  String buildDeniedCallbackUri(String redirectUri, {String? state}) {
    final uri = Uri.parse(redirectUri);
    final query = Map<String, String>.from(uri.queryParameters);
    query['error'] = 'access_denied';
    query['error_description'] = 'The user denied the authorization request.';
    if (state?.isNotEmpty == true) query['state'] = state!;
    return uri.replace(queryParameters: query).toString();
  }
}
