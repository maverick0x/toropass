class ErrorResponse {
  int? code;
  bool? success;
  String? path;
  String? message;
  DateTime? timestamp;

  ErrorResponse({
    this.code,
    this.path,
    this.success,
    this.message,
    this.timestamp,
  });

  ErrorResponse.fromJson(Map<String, dynamic> json) {
    path = json['path'];
    code = json['statusCode'];
    success = json['success'];
    final rawMessage = json['message'];
    if (rawMessage is List) {
      message = rawMessage.map((item) => item.toString()).join('\n');
    } else {
      message = rawMessage?.toString();
    }
    timestamp = DateTime.tryParse(json["timestamp"] ?? "");
  }
}

class SuccessResponse {
  dynamic data;
  bool? success;
  String? message;
  DateTime? timestamp;

  SuccessResponse({this.data, this.success, this.message, this.timestamp});

  SuccessResponse.fromJson(Map<String, dynamic> json) {
    data = json['data'];
    success = json['success'];
    message = json['message'];
    timestamp = DateTime.tryParse(json["timestamp"] ?? "");
  }
}
