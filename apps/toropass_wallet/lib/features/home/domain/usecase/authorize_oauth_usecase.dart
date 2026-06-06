import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/resource/data_state.dart';
import '../../../../core/config/resource/usecase.dart';
import '../../data/repository/oauth_repository_impl.dart';
import '../entities/oauth_authorize_result_entity.dart';
import '../params/oauth_authorize_params.dart';
import '../repository/oauth_repository.dart';

final authorizeOAuthUseCaseProvider = Provider((ref) {
  final repo = ref.watch(oauthRepositoryProvider);
  return AuthorizeOAuthUseCase(repo);
});

class AuthorizeOAuthUseCase
    extends UseCase<DataState<OAuthAuthorizeResultEntity>, OAuthAuthorizeParams> {
  final OAuthRepository _repo;

  AuthorizeOAuthUseCase(this._repo);

  @override
  Future<DataState<OAuthAuthorizeResultEntity>> call(
    OAuthAuthorizeParams params,
  ) async {
    try {
      final result = await _repo.authorize(params);
      return DataSuccess(data: result);
    } catch (e, st) {
      return DataFailed(error: e.toString(), trace: st);
    }
  }
}
