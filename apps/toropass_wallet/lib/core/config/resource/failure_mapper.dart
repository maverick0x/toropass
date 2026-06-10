import 'data_state.dart';
import 'exception.dart';

enum FailureType { api, server, unknown }

class Failure {
  final FailureType type;
  final String message;
  final int? code;
  final String? path;

  const Failure({
    required this.type,
    required this.message,
    this.code,
    this.path,
  });
}

class FailureMapper {
  static DataFailed<T> toDataFailed<T>(Object error, StackTrace trace) {
    final failure = map(error);

    return DataFailed<T>(
      code: failure.code,
      error: failure.type.name,
      message: failure.message,
      trace: trace,
    );
  }

  static Failure map(Object error) {
    if (error is ApiException) {
      return _mapApiException(error);
    }

    final message = _clean(error.toString());

    return Failure(
      type: FailureType.unknown,
      message: message.isEmpty ? 'An unexpected error occurred.' : message,
    );
  }

  static Failure _mapApiException(ApiException error) {
    final message = _clean(error.message);

    if (_isServerError(error.code)) {
      return Failure(
        type: FailureType.server,
        code: error.code,
        path: error.path,
        message: message.isNotEmpty
            ? message
            : 'Server error. Please try again later.',
      );
    }

    return Failure(
      type: FailureType.api,
      code: error.code,
      path: error.path,
      message: message.isNotEmpty
          ? message
          : 'Request failed. Please try again.',
    );
  }

  static bool _isServerError(int? code) {
    return code != null && code >= 500 && code <= 599;
  }

  static String _clean(String? value) {
    return (value ?? '')
        .replaceFirst('Exception: ', '')
        .replaceFirst('ApiException: ', '')
        .trim();
  }
}
