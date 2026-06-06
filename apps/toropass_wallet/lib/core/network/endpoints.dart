// ignore_for_file: non_constant_identifier_names
// ignore_for_file: constant_identifier_names

import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  static final String BASE_URL = dotenv.env['API_BASE_URL'] ?? '';

  // WALLETS
  static const String WALLET = 'wallets';
  static const String CHECK_TNS = '$WALLET/tns';
  static const String CREATE_WALLET = '$WALLET/create';
  static const String VALIDATE_WALLET = '$WALLET/validate';
  static const String CHANGE_PASSWORD = '$WALLET/change-password';
  static const String WALLET_REFRESH = '$WALLET/refresh';
}
