import '../../../../core/network/token/token_model.dart';
import '../../domain/entities/wallet_entity.dart';

class WalletModel extends WalletEntity {
  const WalletModel({
    super.username,
    super.address,
    super.tnsName,
    super.network,
    super.tokens,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      username: json['username'] as String?,
      address: json['address'] as String?,
      tnsName: json['tnsName'] as String?,
      network: json['network'] as String?,
      tokens: json['tokens'] != null
          ? TokenModel.fromJson(json['tokens'] as Map<String, dynamic>)
          : null,
    );
  }
}
