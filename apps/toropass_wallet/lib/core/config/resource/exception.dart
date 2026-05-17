class ApiServiceException implements Exception {
  int? code;
  String? path;
  String? message;
  DateTime? timestamp;

  ApiServiceException({this.code, this.path, this.message, this.timestamp});

  @override
  String toString() {
    return message ?? 'An error occurred';
  }
}
