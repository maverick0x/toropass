class RegisterOAuthAppParams {
  final String name;
  final String redirectUri;

  const RegisterOAuthAppParams({required this.name, required this.redirectUri});

  Map<String, dynamic> toJson() => {"name": name, "redirectUri": redirectUri};
}
