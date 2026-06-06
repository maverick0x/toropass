import '../../domain/entities/profile_entity.dart';
import '../../../auth/data/models/wallet_model.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    super.id,
    super.kycVerified,
    super.kycAnchorHash,
    super.wallet,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String?,
      kycVerified: json['kycVerified'] as bool?,
      kycAnchorHash: json['kycAnchorHash'] as String?,
      wallet: json['wallet'] != null
          ? WalletModel.fromJson(json['wallet'] as Map<String, dynamic>)
          : null,
    );
  }
}
