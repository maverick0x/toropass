import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config/resource/data_state.dart';
import '../../services/storage_service.dart';
import 'token_entity.dart';
import 'token_state_model.dart';
import 'token_usecase.dart';

part 'token_notifier.g.dart';

@Riverpod(keepAlive: true)
class TokenNotifier extends _$TokenNotifier {
  @override
  Future<TokenStateModel> build() async {
    final storage = ref.read(storageServiceProvider);
    final refreshToken = await storage.getRefreshTokenFromDisk();

    // Silent refresh logic: If a refresh token exists, attempt to fetch a new access token using it
    if (refreshToken != null && refreshToken.isNotEmpty) {
      final useCase = ref.read(fetchTokenUseCaseProvider);
      final result = await useCase(refreshToken);

      if (result is DataSuccess && result.data != null) {
        updateTokens(result.data!);
      } else {
        await storage.clearRefreshToken();
        return const TokenStateModel();
      }
    }

    return TokenStateModel(refreshToken: refreshToken);
  }

  Future updateTokens(TokenEntity model) async {
    if (model.accessToken == null || model.refreshToken == null) return;

    final storage = ref.read(storageServiceProvider);
    await storage.saveRefreshToken(model.refreshToken ?? "");

    final currentState = state.value;
    if (currentState != null) {
      state = AsyncData(
        currentState.copyWith(
          token: model.accessToken,
          refreshToken: model.refreshToken,
        ),
      );
    } else {
      state = AsyncData(TokenStateModel(ready: true));
    }
  }

  void markReady(bool ready) {
    final currentState = state.value;
    if (currentState != null) {
      state = AsyncData(currentState.copyWith(ready: ready));
    }
  }

  Future clearTokens() async {
    final storage = ref.read(storageServiceProvider);
    await storage.clearRefreshToken();

    final currentState = state.value;
    if (currentState != null) {
      state = AsyncData(currentState.copyWith(token: null, refreshToken: null));
    } else {
      state = const AsyncData(TokenStateModel(ready: true));
    }
  }
}
