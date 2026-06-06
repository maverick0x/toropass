import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import 'token_entity.dart';
import 'token_model.dart';

final tokenRepositoryProvider = Provider((ref) {
  final client = ref.watch(apiClientProvider);
  return TokenRepository(client);
});

class TokenRepository {
  final ApiClient client;

  TokenRepository(this.client);

  Future<TokenEntity> getToken(String refreshToken) async {
    final result = await client.post(
      endpoint: ApiEndpoints.WALLET_REFRESH,
      body: {"refreshToken": refreshToken},
      useToken: false,
    );

    return TokenModel.fromJson(result.data);
  }
}
