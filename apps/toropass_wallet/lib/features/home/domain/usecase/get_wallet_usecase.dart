import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/resource/data_state.dart';
import '../../../../core/config/resource/usecase.dart';
import '../../data/repository/user_repository_impl.dart';
import '../entities/profile_entity.dart';
import '../repository/user_repository.dart';

final getWalletUseCaseProvider = Provider((ref) {
  final repo = ref.watch(userRepositoryProvider);
  return GetWalletUseCase(repo);
});

class GetWalletUseCase extends UseCase<DataState<ProfileEntity>, void> {
  final UserRepository _repo;

  GetWalletUseCase(this._repo);

  @override
  Future<DataState<ProfileEntity>> call(_) async {
    try {
      final result = await _repo.getWallet();
      return DataSuccess(data: result);
    } catch (e, st) {
      return DataFailed(error: e.toString(), trace: st);
    }
  }
}
