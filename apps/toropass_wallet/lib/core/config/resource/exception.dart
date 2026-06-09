class ApiException implements Exception {
  int? code;
  String? path;
  String? message;
  DateTime? timestamp;

  ApiException({this.code, this.path, this.message, this.timestamp});

  @override
  String toString() {
    return message ?? 'An error occurred';
  }

  static String messageForStatusCode(int? statusCode, {String? fallback}) {
    switch (statusCode) {
      case 400:
        return 'Bad request';
      case 401:
        return 'Unauthorized. Please log in again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'Resource not found.';
      case 408:
        return 'Request timeout. Please try again.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Server is temporarily unavailable. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      case 504:
        return 'Server timeout. Please try again later.';
      default:
        return fallback ?? 'An unexpected error occurred.';
    }
  }
}
