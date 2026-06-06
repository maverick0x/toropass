import '../../domain/entities/developer_app_entity.dart';

class DeveloperAppModel extends DeveloperAppEntity {
  const DeveloperAppModel({
    super.id,
    super.name,
    super.clientId,
    super.clientSecret,
    super.redirectUri,
    super.isActive,
    super.createdAt,
  });

  factory DeveloperAppModel.fromJson(Map<String, dynamic> json) {
    return DeveloperAppModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      clientId: json['clientId'] as String?,
      clientSecret: json['clientSecret'] as String?,
      redirectUri: json['redirectUri'] as String?,
      isActive: json['isActive'] as bool?,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}
