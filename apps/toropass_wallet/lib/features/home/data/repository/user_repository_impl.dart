import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/resource/response.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/params/change_password_params.dart';
import '../../domain/repository/user_repository.dart';
import '../models/profile_model.dart';

final userRepositoryProvider = Provider((ref) {
  final client = ref.watch(apiClientProvider);
  return UserRepositoryImpl(client);
});

class UserRepositoryImpl implements UserRepository {
  final ApiClient _client;

  UserRepositoryImpl(this._client);

  @override
  Future<ProfileEntity> getWallet() async {
    final response = await _client.get(
      endpoint: ApiEndpoints.WALLET,
      useToken: false,
      silent: false,
    );

    return ProfileModel.fromJson(response.data);
  }

  @override
  Future<SuccessResponse> changePassword(ChangePasswordParams params) async {
    final response = await _client.post(
      endpoint: ApiEndpoints.CHANGE_PASSWORD,
      useToken: true,
      silent: false,
      body: params.toJson(),
    );

    return response;
  }
}
