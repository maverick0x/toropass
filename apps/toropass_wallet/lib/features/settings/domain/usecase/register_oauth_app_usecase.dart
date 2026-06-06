import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/resource/data_state.dart';
import '../../../../core/config/resource/usecase.dart';
import '../../data/repository/developer_repository_impl.dart';
import '../entities/developer_app_entity.dart';
import '../params/register_oauth_app_params.dart';
import '../repository/developer_repository.dart';

final registerOAuthAppUseCaseProvider = Provider((ref) {
  final repo = ref.watch(developerRepositoryProvider);
  return RegisterOAuthAppUseCase(repo);
});

class RegisterOAuthAppUseCase
    extends UseCase<DataState<DeveloperAppEntity>, RegisterOAuthAppParams> {
  final DeveloperRepository _repo;

  RegisterOAuthAppUseCase(this._repo);

  @override
  Future<DataState<DeveloperAppEntity>> call(
    RegisterOAuthAppParams params,
  ) async {
    try {
      final result = await _repo.registerApp(params);
      return DataSuccess(data: result);
    } catch (e, st) {
      return DataFailed(error: e.toString(), trace: st);
    }
  }
}
