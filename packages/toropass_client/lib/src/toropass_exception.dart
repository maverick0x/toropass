class ToroPassException implements Exception {
  final String message;
  final int? statusCode;
  final Object? cause;

  const ToroPassException({required this.message, this.statusCode, this.cause});

  @override
  String toString() => message;
}

class ToroPassTokenInvalidException extends ToroPassException {
  const ToroPassTokenInvalidException({
    super.message = 'ToroPass access token is expired or consent was revoked.',
    super.statusCode,
    super.cause,
  });
}
