import 'package:equatable/equatable.dart';

class ConsentEntity extends Equatable {
  final String? appId;
  final String? appName;
  final List<String> scopes;
  final DateTime? grantedAt;
  final DateTime? expiresAt;

  const ConsentEntity({
    this.appId,
    this.appName,
    this.scopes = const [],
    this.grantedAt,
    this.expiresAt,
  });

  @override
  List<Object?> get props => [appId, appName, scopes, grantedAt, expiresAt];
}
