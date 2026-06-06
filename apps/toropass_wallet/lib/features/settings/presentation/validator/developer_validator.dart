class DeveloperValidator {
  static String? validateName(String value) {
    if (value.trim().isEmpty) {
      return 'App name is required';
    }
    if (value.trim().length < 3) {
      return 'App name must be at least 3 characters';
    }
    return null;
  }

  static String? validateRedirectUri(String value) {
    final uri = Uri.tryParse(value.trim());
    if (value.trim().isEmpty) {
      return 'Redirect URI is required';
    }
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return 'Enter a valid redirect URI';
    }
    return null;
  }
}
