class OAuthAuthorizeParams {
  final String clientId;
  final String redirectUri;
  final List<String> scopes;

  const OAuthAuthorizeParams({
    required this.clientId,
    required this.redirectUri,
    required this.scopes,
  });

  Map<String, dynamic> toJson() => {
        "client_id": clientId,
        "redirect_uri": redirectUri,
        "scopes": scopes,
      };
}
