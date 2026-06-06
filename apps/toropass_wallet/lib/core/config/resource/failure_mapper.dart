import 'data_state.dart';
import 'exception.dart';

enum AppFailureType {
  invalidCredentials,
  sessionExpired,
  security,
  consentRevoked,
  validation,
  network,
  timeout,
  server,
  unknown,
}

class AppFailure {
  final AppFailureType type;
  final String message;
  final int? code;
  final String? path;

  const AppFailure({
    required this.type,
    required this.message,
    this.code,
    this.path,
  });
}

class AppFailureMapper {
  static DataFailed<T> toDataFailed<T>(Object error, StackTrace trace) {
    final failure = map(error);
    return DataFailed(
      code: failure.code,
      error: failure.message,
      message: failure.type.name,
      trace: trace,
    );
  }

  static AppFailure map(Object error) {
    if (error is ApiServiceException) {
      return _mapApiError(error);
    }

    final message = _clean(error.toString());
    return AppFailure(
      type: AppFailureType.unknown,
      message: message.isEmpty ? 'An unexpected error occurred.' : message,
    );
  }

  static AppFailure _mapApiError(ApiServiceException error) {
    final rawMessage = _clean(error.message);
    final normalized = rawMessage.toLowerCase();

    if (_containsAny(normalized, [
      'authentication required but no token found',
      'session expired',
      'expired access token',
      'refresh token',
      'jwt',
    ])) {
      return AppFailure(
        type: AppFailureType.sessionExpired,
        code: error.code,
        path: error.path,
        message: 'Your session has expired. Please sign in again.',
      );
    }

    if (_containsAny(normalized, ['incorrect password', 'invalid password'])) {
      return AppFailure(
        type: AppFailureType.invalidCredentials,
        code: error.code,
        path: error.path,
        message: 'The password you entered is incorrect.',
      );
    }

    if ((error.code == 401 || error.code == 403) &&
        _containsAny(normalized, ['password', 'unauthorized', 'invalid'])) {
      return AppFailure(
        type: AppFailureType.invalidCredentials,
        code: error.code,
        path: error.path,
        message: 'The password you entered is incorrect.',
      );
    }

    if (_containsAny(normalized, [
      'hmac',
      'signature',
      'timestamp',
      'device id',
      'api key',
      'security exception',
      'proxy detected',
    ])) {
      return AppFailure(
        type: AppFailureType.security,
        code: error.code,
        path: error.path,
        message:
            'Security validation failed. Please try again or update the app.',
      );
    }

    if (_containsAny(normalized, [
      'consent revoked',
      'consent not found',
      'permission revoked',
    ])) {
      return AppFailure(
        type: AppFailureType.consentRevoked,
        code: error.code,
        path: error.path,
        message:
            'This app permission is no longer available. Refresh and try again.',
      );
    }

    if (_containsAny(normalized, ['connection timeout', 'timeout'])) {
      return AppFailure(
        type: AppFailureType.timeout,
        code: error.code,
        path: error.path,
        message: 'The request timed out. Please try again.',
      );
    }

    if (_containsAny(normalized, [
      'no internet',
      'connection refused',
      'unable to reach',
    ])) {
      return AppFailure(
        type: AppFailureType.network,
        code: error.code,
        path: error.path,
        message: 'Unable to reach ToroPass right now. Check your connection.',
      );
    }

    if (error.code != null && error.code! >= 500) {
      return AppFailure(
        type: AppFailureType.server,
        code: error.code,
        path: error.path,
        message: 'ToroPass is having trouble right now. Please try again soon.',
      );
    }

    if (rawMessage.isNotEmpty) {
      return AppFailure(
        type: AppFailureType.validation,
        code: error.code,
        path: error.path,
        message: rawMessage,
      );
    }

    return AppFailure(
      type: AppFailureType.unknown,
      code: error.code,
      path: error.path,
      message: 'An unexpected error occurred. Please try again.',
    );
  }

  static bool _containsAny(String message, List<String> needles) {
    return needles.any(message.contains);
  }

  static String _clean(String? value) {
    return (value ?? '').replaceFirst('Exception: ', '').trim();
  }
}
