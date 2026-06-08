import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/resource/response.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/network/endpoints.dart';
import '../../domain/params/change_password_params.dart';
import '../../domain/repository/settings_repository.dart';

final settingsRepositoryProvider = Provider((ref) {
  final client = ref.watch(apiClientProvider);
  return SettingsRepositoryImpl(client);
});

class SettingsRepositoryImpl implements SettingsRepository {
  final ApiClient _client;

  SettingsRepositoryImpl(this._client);

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
