import '../config/resource/response.dart';

class ResponseParser {
  static SuccessResponse parseSuccess(dynamic data) {
    if (data is Map<String, dynamic>) {
      return SuccessResponse.fromJson(data);
    }

    throw FormatException(
      'Invalid success response format. Expected JSON object but got ${data.runtimeType}.',
    );
  }

  static ErrorResponse? parseError(dynamic data) {
    if (data is Map<String, dynamic>) {
      return ErrorResponse.fromJson(data);
    }

    return null;
  }
}
