import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/resource/data_state.dart';
import '../../../core/config/resource/usecase.dart';
import '../../config/resource/exception.dart';
import 'token_model.dart';
import 'token_repository.dart';

final fetchTokenUseCaseProvider = Provider((ref) {
  final repository = ref.watch(tokenRepositoryProvider);
  return FetchTokenUseCase(repository);
});

class FetchTokenUseCase extends UseCase<DataState<TokenModel>, String> {
  final TokenRepository repository;
  //
  FetchTokenUseCase(this.repository);

  @override
  Future<DataState<TokenModel>> call(String params) async {
    try {
      final result = await repository.getToken(params);

      return DataSuccess(data: result);
    } on ApiServiceException catch (e, stackTrace) {
      return DataFailed(
        code: e.code,
        path: e.path,
        error: e.message,
        trace: stackTrace,
      );
    } catch (e, stackTrace) {
      return DataFailed(error: e.toString(), trace: stackTrace);
    }
  }
}
