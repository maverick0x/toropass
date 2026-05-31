import '../../../../core/config/resource/data_state.dart';
import '../../domain/entities/tns_entity.dart';

class AuthStateModel {
  final String username;
  final String privateKey;
  final String password;
  final DataState<TnsEntity> tnsState;

  AuthStateModel({
    this.username = '',
    this.privateKey = '',
    this.password = '',
    this.tnsState = const DataInitial(),
  });

  AuthStateModel copyWith({
    String? username,
    String? privateKey,
    String? password,
    DataState<TnsEntity>? tnsState,
  }) {
    return AuthStateModel(
      username: username ?? this.username,
      privateKey: privateKey ?? this.privateKey,
      password: password ?? this.password,
      tnsState: tnsState ?? this.tnsState,
    );
  }
}
