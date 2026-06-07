import 'package:flutter/foundation.dart';

class AppLogger {
  static void log(
    String message, {
    String name = '',
    Object? error,
    Object? object,
    StackTrace? trace,
  }) {
    if (kDebugMode) {
      final buffer = StringBuffer();

      if (name.isNotEmpty) {
        buffer.write('[$name] ');
      }

      buffer.write(message);

      if (error != null) {
        buffer.write('\nError: $error');
      }

      if (trace != null) {
        buffer.write('\nStackTrace: $trace');
      }

      debugPrint(buffer.toString());

      if (object != null) {
        debugPrint('Object: $object');
      }
    }
  }
}
