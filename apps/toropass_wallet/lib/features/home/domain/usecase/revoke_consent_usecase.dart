import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/resource/data_state.dart';
import '../../../../core/config/resource/failure_mapper.dart';
import '../../../../core/config/resource/response.dart';
import '../../../../core/config/resource/usecase.dart';
import '../../data/repository/user_repository_impl.dart';
import '../repository/user_repository.dart';

final revokeConsentUseCaseProvider = Provider((ref) {
  final repo = ref.watch(userRepositoryProvider);
  return RevokeConsentUseCase(repo);
});

class RevokeConsentUseCase extends UseCase<DataState<SuccessResponse>, String> {
  final UserRepository _repo;

  RevokeConsentUseCase(this._repo);

  @override
  Future<DataState<SuccessResponse>> call(String appId) async {
    try {
      final result = await _repo.revokeConsent(appId);
      return DataSuccess(data: result);
    } catch (e, st) {
      return FailureMapper.toDataFailed(e, st);
    }
  }
}
