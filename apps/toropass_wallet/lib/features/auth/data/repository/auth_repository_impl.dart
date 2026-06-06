import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../../domain/entities/tns_entity.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/params/wallet_params.dart';
import '../../domain/repository/auth_repository.dart';
import '../models/tns_model.dart';
import '../models/wallet_model.dart';

final authRepositoryProvider = Provider((ref) {
  final client = ref.watch(apiClientProvider);
  return AuthRepositoryImpl(client);
});

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _client;

  AuthRepositoryImpl(this._client);

  @override
  Future<TnsEntity> checkTNSName(String username) async {
    final response = await _client.get(
      endpoint: "${ApiEndpoints.CHECK_TNS}?username=$username",
      useToken: false,
      silent: false,
    );

    return TnsModel.fromJson(response.data);
  }

  @override
  Future<WalletEntity> createWallet(WalletParams params) async {
    final response = await _client.post(
      endpoint: ApiEndpoints.CREATE_WALLET,
      useToken: false,
      silent: false,
      body: params.toJson(),
    );

    return WalletModel.fromJson(response.data);
  }

  @override
  Future<WalletEntity> validateWallet(WalletParams params) async {
    final response = await _client.post(
      endpoint: ApiEndpoints.VALIDATE_WALLET,
      useToken: false,
      silent: false,
      body: params.toJson(),
    );

    return WalletModel.fromJson(response.data);
  }

}
