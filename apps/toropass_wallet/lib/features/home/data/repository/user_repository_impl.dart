import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/resource/response.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../../domain/entities/consent_entity.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/params/verify_kyc_params.dart';
import '../../domain/repository/user_repository.dart';
import '../models/consent_model.dart';
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
      useToken: true,
      silent: false,
    );

    return ProfileModel.fromJson(response.data);
  }

  @override
  Future<List<ConsentEntity>> getConsents() async {
    final response = await _client.get(
      endpoint: ApiEndpoints.userConsents(),
      useToken: true,
      silent: false,
    );

    final list = response.data as List<dynamic>? ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(ConsentModel.fromJson)
        .toList();
  }

  @override
  Future<SuccessResponse> revokeConsent(String appId) async {
    final response = await _client.delete(
      endpoint: ApiEndpoints.revokeConsent(appId),
      useToken: true,
      silent: false,
    );

    return response;
  }

  @override
  Future<SuccessResponse> verifyKyc(VerifyKycParams params) async {
    final response = await _client.post(
      endpoint: ApiEndpoints.VERIFY_KYC,
      useToken: true,
      silent: false,
      body: params.toJson(),
    );

    return response;
  }
}
