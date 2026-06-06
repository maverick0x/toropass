// ignore_for_file: non_constant_identifier_names
// ignore_for_file: constant_identifier_names

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  static final String BASE_URL = kDebugMode
      ? 'http://localhost:3000/api/v1/'
      : 'https://api.toropass.app/api/v1/';

  // WALLETS
  static const String WALLET = 'wallets';
  static const String CHECK_TNS = '$WALLET/tns';
  static const String CREATE_WALLET = '$WALLET/create';
  static const String VALIDATE_WALLET = '$WALLET/validate';
  static const String CHANGE_PASSWORD = '$WALLET/change-password';
  static const String WALLET_REFRESH = '$WALLET/refresh';

  // KYC
  static const String KYC = 'kyc';
  static const String VERIFY_KYC = '$KYC/verify';

  // CONSENTS
  static const String CONSENTS = 'conscents';
  static String userConsents() => CONSENTS;
  static String revokeConsent(String appId) => '$CONSENTS/$appId';

  // OAUTH
  static const String OAUTH = 'oauth';
  static const String REGISTER_OAUTH_APP = '$OAUTH/apps/register';
  static const String LIST_OAUTH_APPS = '$OAUTH/apps';
  static String deleteOAuthApp(String appId) => '$OAUTH/apps/$appId';
  static const String AUTHORIZE_OAUTH = '$OAUTH/authorize';
  static const String OAUTH_TOKEN = '$OAUTH/token';
  static const String OAUTH_PROFILE = '$OAUTH/profile';
}
