import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/resource/response.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../../domain/entities/developer_app_entity.dart';
import '../../domain/params/register_oauth_app_params.dart';
import '../models/developer_app_model.dart';

final developerRepositoryProvider = Provider((ref) {
  final client = ref.watch(apiClientProvider);
  return DeveloperRepositoryImpl(client);
});

class DeveloperRepositoryImpl {
  final ApiClient _client;

  DeveloperRepositoryImpl(this._client);

  Future<DeveloperAppEntity> registerApp(RegisterOAuthAppParams params) async {
    final response = await _client.post(
      endpoint: ApiEndpoints.REGISTER_OAUTH_APP,
      body: params.toJson(),
      useToken: true,
      silent: false,
    );

    return DeveloperAppModel.fromJson(
      response.data as Map<String, dynamic>? ?? const {},
    );
  }

  Future<List<DeveloperAppEntity>> getApps() async {
    final response = await _client.get(
      endpoint: ApiEndpoints.LIST_OAUTH_APPS,
      useToken: true,
      silent: false,
    );

    final list = response.data as List<dynamic>? ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(DeveloperAppModel.fromJson)
        .toList();
  }

  Future<SuccessResponse> deleteApp(String appId) async {
    final response = await _client.delete(
      endpoint: ApiEndpoints.deleteOAuthApp(appId),
      useToken: true,
      silent: false,
    );

    return response;
  }
}
