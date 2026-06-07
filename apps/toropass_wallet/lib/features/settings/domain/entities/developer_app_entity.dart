import 'package:equatable/equatable.dart';

class DeveloperAppEntity extends Equatable {
  final String? id;
  final String? name;
  final String? clientId;
  final String? clientSecret;
  final String? redirectUri;
  final bool? isActive;
  final DateTime? createdAt;

  const DeveloperAppEntity({
    this.id,
    this.name,
    this.clientId,
    this.clientSecret,
    this.redirectUri,
    this.isActive,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    clientId,
    clientSecret,
    redirectUri,
    isActive,
    createdAt,
  ];
}
