import '../entities/tns_entity.dart';
import '../entities/wallet_entity.dart';
import '../params/wallet_params.dart';

abstract class AuthRepository {
  Future<TnsEntity> checkTNSName(String username);

  Future<WalletEntity> createWallet(WalletParams params);

  Future<WalletEntity> validateWallet(WalletParams params);
}
