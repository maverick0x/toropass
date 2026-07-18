import 'package:flutter_test/flutter_test.dart';
import 'package:toropass_wallet/features/auth/presentation/validator/auth_validator.dart';
import 'package:toropass_wallet/features/home/presentation/validator/kyc_validator.dart';
import 'package:toropass_wallet/features/settings/presentation/validator/change_password_validator.dart';
import 'package:toropass_wallet/features/settings/presentation/validator/developer_validator.dart';

void main() {
  group('AuthValidator', () {
    test('validates usernames and passwords', () {
      expect(AuthValidator.validateUsername('mave'), isNotNull);
      expect(AuthValidator.validateUsername('maverick'), isNull);
      expect(AuthValidator.validatePassword('short'), isNotNull);
      expect(AuthValidator.validatePassword('secure-password'), isNull);
    });
  });

  group('KycValidator', () {
    test('normalizes local and international Nigerian phone numbers', () {
      for (final input in [
        '0801 234 5678',
        '+234 801 234 5678',
        '2348012345678',
      ]) {
        expect(KycValidator.sanitizePhoneNumber(input), '8012345678');
        expect(
          KycValidator.formatPhoneNumberForApi(input),
          '+2348012345678',
        );
      }
    });

    test('formats phone numbers and dates for display and transport', () {
      expect(
        KycValidator.formatPhoneNumberForDisplay('+2348012345678'),
        '801 234 5678',
      );
      expect(KycValidator.formatDob('18/07/2000'), '2000-07-18');
      expect(KycValidator.validateDob('2000-07-18'), isNull);
      expect(KycValidator.validateDob('18-07-2000'), isNotNull);
    });
  });

  group('Settings validators', () {
    test('validates redirect URIs and password confirmation', () {
      expect(
        DeveloperValidator.validateRedirectUri(
          'toropassclient://oauth/callback',
        ),
        isNull,
      );
      expect(DeveloperValidator.validateRedirectUri('callback'), isNotNull);
      expect(
        ChangePasswordValidator.validateConfirmPassword(
          'secure-password',
          'different-password',
        ),
        isNotNull,
      );
      expect(
        ChangePasswordValidator.validateConfirmPassword(
          'secure-password',
          'secure-password',
        ),
        isNull,
      );
    });
  });
}
