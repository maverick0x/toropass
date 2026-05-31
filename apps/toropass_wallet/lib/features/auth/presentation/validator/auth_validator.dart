class AuthValidator {
  static String? validateUsername(String username) {
    if (username.trim().isEmpty) {
      return 'Username cannot be empty.';
    } else if (username.length < 3) {
      return 'Username must be at least 3 characters.';
    }
    return null;
  }

  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password cannot be empty.';
    } else if (password.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    return null;
  }
}
