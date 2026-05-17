import 'dart:developer' as dev;

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
      dev.log(message, time: DateTime.now(), name: name, error: error, stackTrace: trace);
      if (object != null) {
        dev.inspect(object);
      }
    }
  }
}
