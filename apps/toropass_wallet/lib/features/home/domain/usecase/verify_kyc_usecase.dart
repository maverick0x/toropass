import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/resource/data_state.dart';
import '../../../../core/config/resource/response.dart';
import '../../../../core/config/resource/usecase.dart';
import '../../data/repository/user_repository_impl.dart';
import '../params/verify_kyc_params.dart';
import '../repository/user_repository.dart';

final verifyKycUseCaseProvider = Provider((ref) {
  final repo = ref.watch(userRepositoryProvider);
  return VerifyKycUseCase(repo);
});

class VerifyKycUseCase
    extends UseCase<DataState<SuccessResponse>, VerifyKycParams> {
  final UserRepository _repo;

  VerifyKycUseCase(this._repo);

  @override
  Future<DataState<SuccessResponse>> call(VerifyKycParams params) async {
    try {
      final result = await _repo.verifyKyc(params);
      return DataSuccess(data: result);
    } catch (e, st) {
      return DataFailed(error: e.toString(), trace: st);
    }
  }
}
