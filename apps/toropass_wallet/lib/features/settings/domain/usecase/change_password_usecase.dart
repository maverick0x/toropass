import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/resource/data_state.dart';
import '../../../../core/config/resource/failure_mapper.dart';
import '../../../../core/config/resource/response.dart';
import '../../../../core/config/resource/usecase.dart';
import '../../data/repository/settings_repository_impl.dart';
import '../params/change_password_params.dart';
import '../repository/settings_repository.dart';

final changePasswordUseCaseProvider = Provider((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return ChangePasswordUseCase(repo);
});

class ChangePasswordUseCase
    extends UseCase<DataState<SuccessResponse>, ChangePasswordParams> {
  final SettingsRepository _repo;

  ChangePasswordUseCase(this._repo);

  @override
  Future<DataState<SuccessResponse>> call(ChangePasswordParams params) async {
    try {
      final result = await _repo.changePassword(params);
      return DataSuccess(data: result);
    } catch (error, trace) {
      return FailureMapper.toDataFailed(error, trace);
    }
  }
}
