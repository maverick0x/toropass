class ChangePasswordValidator {
  static String? validateCurrentPassword(String value) {
    if (value.isEmpty) {
      return 'Current password cannot be empty.';
    }
    return null;
  }

  static String? validateNewPassword(String value) {
    if (value.isEmpty) {
      return 'New password cannot be empty.';
    }
    if (value.length < 8) {
      return 'New password must be at least 8 characters.';
    }
    return null;
  }

  static String? validateConfirmPassword(
    String newPassword,
    String confirmPassword,
  ) {
    if (confirmPassword.isEmpty) {
      return 'Please confirm your new password.';
    }
    if (newPassword != confirmPassword) {
      return 'Passwords do not match.';
    }
    return null;
  }
}
