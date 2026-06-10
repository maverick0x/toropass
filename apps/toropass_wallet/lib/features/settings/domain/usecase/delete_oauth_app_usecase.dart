import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/resource/data_state.dart';
import '../../../../core/config/resource/failure_mapper.dart';
import '../../../../core/config/resource/response.dart';
import '../../../../core/config/resource/usecase.dart';
import '../../data/repository/developer_repository_impl.dart';
import '../repository/developer_repository.dart';

final deleteOAuthAppUseCaseProvider = Provider((ref) {
  final repo = ref.watch(developerRepositoryProvider);
  return DeleteOAuthAppUseCase(repo);
});

class DeleteOAuthAppUseCase
    extends UseCase<DataState<SuccessResponse>, String> {
  final DeveloperRepository _repo;

  DeleteOAuthAppUseCase(this._repo);

  @override
  Future<DataState<SuccessResponse>> call(String appId) async {
    try {
      final result = await _repo.deleteApp(appId);
      return DataSuccess(data: result);
    } catch (e, st) {
      return FailureMapper.toDataFailed(e, st);
    }
  }
}
