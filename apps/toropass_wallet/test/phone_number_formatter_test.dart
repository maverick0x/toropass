import 'package:flutter_test/flutter_test.dart';
import 'package:toropass_wallet/features/home/presentation/formatter/phone_number_formatter.dart';

void main() {
  test('formats phone input without duplicating the country code', () {
    final formatter = PhoneNumberFormatter();

    final result = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(text: '+234 801 234 5678'),
    );

    expect(result.text, '801 234 5678');
    expect(result.selection.baseOffset, result.text.length);
  });
}
