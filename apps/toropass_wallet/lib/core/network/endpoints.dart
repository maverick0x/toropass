// ignore_for_file: non_constant_identifier_names
// ignore_for_file: constant_identifier_names

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  static final String BASE_URL = (() {
    final env = dotenv.env['API_BASE_URL'] ?? '';
    if (!kIsWeb) {
      try {
        if (Platform.isAndroid && env.contains('localhost')) {
          return env.replaceAll('localhost', '10.0.2.2');
        }
      } catch (_) {}
    }
    return env;
  })();

  // WALLETS
  static const String CHECK_TNS = 'wallets/tns';
  static const String CREATE_WALLET = 'wallets/create';
  static const String VALIDATE_WALLET = 'wallets/validate';
  static const String CHANGE_PASSWORD = 'wallets/change-password';
  static const String WALLET_REFRESH = 'wallets/refresh';
}
