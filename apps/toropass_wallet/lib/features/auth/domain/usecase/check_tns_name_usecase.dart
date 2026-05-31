import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/resource/data_state.dart';
import '../../../../core/config/resource/exception.dart';
import '../../../../core/config/resource/usecase.dart';
import '../../data/repository/auth_repository_impl.dart';
import '../entities/tns_entity.dart';
import '../repository/auth_repository.dart';

final checkTNSNameUseCaseProvider = Provider((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return CheckTNSNameUseCase(repository);
});

class CheckTNSNameUseCase extends UseCase<DataState<TnsEntity>, String> {
  final AuthRepository repository;

  CheckTNSNameUseCase(this.repository);

  @override
  Future<DataState<TnsEntity>> call(String username) async {
    try {
      final result = await repository.checkTNSName(username);
      return DataSuccess(data: result);
    } on ApiServiceException catch (e, stackTrace) {
      return DataFailed(code: e.code, error: e.message, trace: stackTrace);
    } catch (e, stackTrace) {
      return DataFailed(error: e.toString(), trace: stackTrace);
    }
  }
}
