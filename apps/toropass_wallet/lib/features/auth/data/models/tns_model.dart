import '../../domain/entities/tns_entity.dart';

class TnsModel extends TnsEntity {
  const TnsModel({super.username, super.message, super.isAvailable});

  factory TnsModel.fromJson(Map<String, dynamic> json) {
    return TnsModel(
      username: json['username'] as String,
      message: json['message'] as String,
      isAvailable: json['isAvailable'] as bool,
    );
  }
}
