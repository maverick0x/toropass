import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/resource/data_state.dart';
import '../../../../core/config/resource/usecase.dart';
import '../../data/repository/developer_repository_impl.dart';
import '../entities/developer_app_entity.dart';
import '../repository/developer_repository.dart';

final getOAuthAppsUseCaseProvider = Provider((ref) {
  final repo = ref.watch(developerRepositoryProvider);
  return GetOAuthAppsUseCase(repo);
});

class GetOAuthAppsUseCase
    extends UseCase<DataState<List<DeveloperAppEntity>>, void> {
  final DeveloperRepository _repo;

  GetOAuthAppsUseCase(this._repo);

  @override
  Future<DataState<List<DeveloperAppEntity>>> call(_) async {
    try {
      final result = await _repo.getApps();
      return DataSuccess(data: result);
    } catch (e, st) {
      return DataFailed(error: e.toString(), trace: st);
    }
  }
}
