import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/resource/data_state.dart';
import '../../../../core/config/resource/failure_mapper.dart';
import '../../../../core/config/resource/usecase.dart';
import '../../data/repository/auth_repository_impl.dart';
import '../entities/wallet_entity.dart';
import '../params/wallet_params.dart';
import '../repository/auth_repository.dart';

final validateWalletUseCaseProvider = Provider((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return ValidateWalletUseCase(repo);
});

class ValidateWalletUseCase
    extends UseCase<DataState<WalletEntity>, WalletParams> {
  final AuthRepository _repo;

  ValidateWalletUseCase(this._repo);

  @override
  Future<DataState<WalletEntity>> call(WalletParams params) async {
    try {
      final result = await _repo.validateWallet(params);
      return DataSuccess(data: result);
    } catch (e, st) {
      return FailureMapper.toDataFailed(e, st);
    }
  }
}
