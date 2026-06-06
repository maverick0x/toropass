import '../../../../core/config/resource/response.dart';
import '../entities/consent_entity.dart';
import '../entities/profile_entity.dart';
import '../params/change_password_params.dart';
import '../params/verify_kyc_params.dart';

abstract class UserRepository {
  Future<ProfileEntity> getWallet();
  Future<List<ConsentEntity>> getConsents();
  Future<SuccessResponse> revokeConsent(String appId);
  Future<SuccessResponse> verifyKyc(VerifyKycParams params);
  Future<SuccessResponse> changePassword(ChangePasswordParams params);
}
