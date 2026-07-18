class OAuthAuthorizeParams {
  final String clientId;
  final String redirectUri;
  final List<String> scopes;
  final String codeChallenge;
  final String codeChallengeMethod;

  const OAuthAuthorizeParams({
    required this.clientId,
    required this.redirectUri,
    required this.scopes,
    required this.codeChallenge,
    required this.codeChallengeMethod,
  });

  Map<String, dynamic> toJson() => {
    "client_id": clientId,
    "redirect_uri": redirectUri,
    "scopes": scopes,
    "code_challenge": codeChallenge,
    "code_challenge_method": codeChallengeMethod,
  };
}
