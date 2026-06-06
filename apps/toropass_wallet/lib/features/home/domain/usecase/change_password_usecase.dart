import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/resource/data_state.dart';
import '../../../../core/config/resource/response.dart';
import '../../../../core/config/resource/usecase.dart';
import '../../data/repository/user_repository_impl.dart';
import '../params/change_password_params.dart';
import '../repository/user_repository.dart';

final changePasswordUseCaseProvider = Provider((ref) {
  final repo = ref.watch(userRepositoryProvider);
  return ChangePasswordUseCase(repo);
});

class ChangePasswordUseCase
    extends UseCase<DataState<SuccessResponse>, ChangePasswordParams> {
  final UserRepository _repo;

  ChangePasswordUseCase(this._repo);

  @override
  Future<DataState<SuccessResponse>> call(ChangePasswordParams params) async {
    try {
      final result = await _repo.changePassword(params);
      return DataSuccess(data: result);
    } catch (e, st) {
      return DataFailed(error: e.toString(), trace: st);
    }
  }
}
