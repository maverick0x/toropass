import '../../../../core/config/resource/response.dart';
import '../entities/developer_app_entity.dart';
import '../params/register_oauth_app_params.dart';

abstract class DeveloperRepository {
  Future<DeveloperAppEntity> registerApp(RegisterOAuthAppParams params);

  Future<List<DeveloperAppEntity>> getApps();

  Future<SuccessResponse> deleteApp(String appId);
}
