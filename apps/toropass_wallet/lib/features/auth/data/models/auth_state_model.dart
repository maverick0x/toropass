import '../../../../core/config/resource/data_state.dart';
import '../../domain/entities/tns_entity.dart';
import '../../domain/entities/wallet_entity.dart';

class AuthStateModel {
  final String username;
  final String privateKey;
  final String password;
  final DataState<TnsEntity> tnsState;
  final DataState<WalletEntity> createWalletState;
  final DataState<WalletEntity> validateWalletState;

  AuthStateModel({
    this.username = '',
    this.privateKey = '',
    this.password = '',
    this.tnsState = const DataInitial(),
    this.createWalletState = const DataInitial(),
    this.validateWalletState = const DataInitial(),
  });

  AuthStateModel copyWith({
    String? username,
    String? privateKey,
    String? password,
    DataState<TnsEntity>? tnsState,
    DataState<WalletEntity>? createWalletState,
    DataState<WalletEntity>? validateWalletState,
  }) {
    return AuthStateModel(
      username: username ?? this.username,
      privateKey: privateKey ?? this.privateKey,
      password: password ?? this.password,
      tnsState: tnsState ?? this.tnsState,
      createWalletState: createWalletState ?? this.createWalletState,
      validateWalletState: validateWalletState ?? this.validateWalletState,
    );
  }
}
