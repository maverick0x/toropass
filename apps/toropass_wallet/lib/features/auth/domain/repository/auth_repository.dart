import '../entities/tns_entity.dart';

abstract class AuthRepository {
  Future<TnsEntity> checkTNSName(String username);
}
