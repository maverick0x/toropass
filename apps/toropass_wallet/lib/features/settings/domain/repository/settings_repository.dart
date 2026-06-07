import '../../../../core/config/resource/response.dart';
import '../params/change_password_params.dart';

abstract class SettingsRepository {
  Future<SuccessResponse> changePassword(ChangePasswordParams params);
}
