import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/resource/data_state.dart';
import '../../../core/config/resource/failure_mapper.dart';
import '../../../core/config/resource/usecase.dart';
import 'token_entity.dart';
import 'token_repository.dart';

final fetchTokenUseCaseProvider = Provider((ref) {
  final repository = ref.watch(tokenRepositoryProvider);
  return FetchTokenUseCase(repository);
});

class FetchTokenUseCase extends UseCase<DataState<TokenEntity>, String> {
  final TokenRepository repository;

  FetchTokenUseCase(this.repository);

  @override
  Future<DataState<TokenEntity>> call(String params) async {
    try {
      final result = await repository.getToken(params);

      return DataSuccess(data: result);
    } catch (e, stackTrace) {
      return AppFailureMapper.toDataFailed(e, stackTrace);
    }
  }
}
