import '../../../../core/config/resource/response.dart';
import '../entities/profile_entity.dart';
import '../params/change_password_params.dart';

abstract class UserRepository {
  Future<ProfileEntity> getWallet();

  Future<SuccessResponse> changePassword(ChangePasswordParams params);
}
