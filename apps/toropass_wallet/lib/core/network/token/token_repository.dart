import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import 'token_model.dart';

final tokenRepositoryProvider = Provider((ref) {
  final client = ref.watch(apiClientProvider);
  return TokenRepository(client);
});

class TokenRepository {
  final ApiClient client;

  TokenRepository(this.client);

  Future<TokenModel> getToken(String refreshToken) async {
    final result = await client.post(
      endpoint: ApiEndpoints.REFRESH_TOKEN,
      body: {"refreshToken": refreshToken},
      useToken: false,
    );

    return TokenModel.fromJson(result.data);
  }
}
