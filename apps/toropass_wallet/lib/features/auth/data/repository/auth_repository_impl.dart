import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/tns_entity.dart';
import '../../domain/repository/auth_repository.dart';
import '../model/tns_model.dart';

final authRepositoryProvider = Provider((ref) {
  final client = ref.watch(apiClientProvider);
  return AuthRepositoryImpl(client);
});

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _client;

  AuthRepositoryImpl(this._client);

  @override
  Future<TnsEntity> checkTNSName(String username) async {
    final response = await _client.get(endpoint: "", useToken: false);

    return TnsModel.fromJson(response.data);
  }
}
