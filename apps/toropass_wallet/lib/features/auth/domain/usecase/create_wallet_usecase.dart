import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/resource/data_state.dart';
import '../../../../core/config/resource/usecase.dart';
import '../../data/repository/auth_repository_impl.dart';
import '../entities/wallet_entity.dart';
import '../params/wallet_params.dart';
import '../repository/auth_repository.dart';

final createWalletUseCaseProvider = Provider((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return CreateWalletUseCase(repo);
});

class CreateWalletUseCase
    extends UseCase<DataState<WalletEntity>, WalletParams> {
  final AuthRepository _repo;

  CreateWalletUseCase(this._repo);

  @override
  Future<DataState<WalletEntity>> call(WalletParams params) async {
    try {
      final result = await _repo.createWallet(params);
      return DataSuccess(data: result);
    } catch (e, st) {
      return DataFailed(error: e.toString(), trace: st);
    }
  }
}
