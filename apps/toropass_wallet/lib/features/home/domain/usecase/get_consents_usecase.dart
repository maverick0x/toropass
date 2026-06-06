import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/resource/data_state.dart';
import '../../../../core/config/resource/failure_mapper.dart';
import '../../../../core/config/resource/usecase.dart';
import '../../data/repository/user_repository_impl.dart';
import '../entities/consent_entity.dart';
import '../repository/user_repository.dart';

final getConsentsUseCaseProvider = Provider((ref) {
  final repo = ref.watch(userRepositoryProvider);
  return GetConsentsUseCase(repo);
});

class GetConsentsUseCase extends UseCase<DataState<List<ConsentEntity>>, void> {
  final UserRepository _repo;

  GetConsentsUseCase(this._repo);

  @override
  Future<DataState<List<ConsentEntity>>> call(void params) async {
    try {
      final result = await _repo.getConsents();
      return DataSuccess(data: result);
    } catch (e, st) {
      return AppFailureMapper.toDataFailed(e, st);
    }
  }
}
