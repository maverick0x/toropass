class KycValidator {
  static const String phoneCountryCode = '+234';

  static String? validateFirstName(String value) {
    if (value.trim().isEmpty) {
      return 'First name is required';
    }
    return null;
  }

  static String? validateLastName(String value) {
    if (value.trim().isEmpty) {
      return 'Last name is required';
    }
    return null;
  }

  static String? validateBvn(String value) {
    if (value.trim().length != 11) {
      return 'BVN must be 11 digits';
    }
    return null;
  }

  static String? validateCurrency(String value) {
    final normalized = value.trim().toUpperCase();
    if (normalized.isEmpty) {
      return 'Currency is required';
    }
    if (normalized.length != 3) {
      return 'Use a 3-letter currency code';
    }
    return null;
  }

  static String? validatePhoneNumber(String value) {
    final normalized = sanitizePhoneNumber(value);
    if (normalized.length != 10) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String sanitizePhoneNumber(String raw) {
    var digits = raw.replaceAll(RegExp(r'\D'), '');

    if (digits.startsWith('234')) {
      digits = digits.substring(3);
    }

    if (digits.startsWith('0') && digits.length == 11) {
      digits = digits.substring(1);
    }

    if (digits.length > 10) {
      digits = digits.substring(digits.length - 10);
    }

    return digits;
  }

  static String formatPhoneNumberForApi(String raw) {
    final normalized = sanitizePhoneNumber(raw);
    return '$phoneCountryCode$normalized';
  }

  static String formatPhoneNumberForDisplay(String raw) {
    final normalized = sanitizePhoneNumber(raw);
    if (normalized.isEmpty) return '';

    final parts = <String>[];
    if (normalized.length <= 3) {
      parts.add(normalized);
    } else if (normalized.length <= 6) {
      parts
        ..add(normalized.substring(0, 3))
        ..add(normalized.substring(3));
    } else {
      parts
        ..add(normalized.substring(0, 3))
        ..add(normalized.substring(3, 6))
        ..add(normalized.substring(6));
    }

    return parts.where((part) => part.isNotEmpty).join(' ');
  }

  static String? validateDob(String value) {
    if (formatDob(value) == null) {
      return 'Use YYYY-MM-DD';
    }
    return null;
  }

  static String? formatDob(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;

    final isoMatch = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
    if (isoMatch != null) {
      return value;
    }

    final slashMatch = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(value);
    if (slashMatch != null) {
      final day = slashMatch.group(1)!;
      final month = slashMatch.group(2)!;
      final year = slashMatch.group(3)!;
      return '$year-$month-$day';
    }

    return null;
  }
}
