import '../../domain/entities/consent_entity.dart';

class ConsentModel extends ConsentEntity {
  const ConsentModel({
    super.appId,
    super.appName,
    super.scopes,
    super.grantedAt,
    super.expiresAt,
  });

  factory ConsentModel.fromJson(Map<String, dynamic> json) {
    return ConsentModel(
      appId: json['appId'] as String?,
      appName: json['appName'] as String?,
      scopes: (json['scopes'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
      grantedAt: DateTime.tryParse(json['grantedAt']?.toString() ?? ''),
      expiresAt: DateTime.tryParse(json['expiresAt']?.toString() ?? ''),
    );
  }
}
