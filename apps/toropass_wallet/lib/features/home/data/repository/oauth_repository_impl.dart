import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/network/endpoints.dart';
import '../../domain/entities/oauth_authorize_result_entity.dart';
import '../../domain/params/oauth_authorize_params.dart';
import '../../domain/repository/oauth_repository.dart';
import '../models/oauth_authorize_result_model.dart';

final oauthRepositoryProvider = Provider((ref) {
  final client = ref.watch(apiClientProvider);
  return OAuthRepositoryImpl(client);
});

class OAuthRepositoryImpl implements OAuthRepository {
  final ApiClient _client;

  OAuthRepositoryImpl(this._client);

  @override
  Future<OAuthAuthorizeResultEntity> authorize(
    OAuthAuthorizeParams params,
  ) async {
    final response = await _client.post(
      endpoint: ApiEndpoints.AUTHORIZE_OAUTH,
      body: params.toJson(),
      useToken: true,
      silent: false,
    );

    return OAuthAuthorizeResultModel.fromJson(
      response.data as Map<String, dynamic>? ?? const {},
    );
  }
}
