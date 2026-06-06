class ToroPassWalletProfile {
  final String address;
  final String tnsName;
  final String network;

  const ToroPassWalletProfile({
    required this.address,
    required this.tnsName,
    required this.network,
  });

  factory ToroPassWalletProfile.fromJson(Map<String, dynamic> json) {
    return ToroPassWalletProfile(
      address: json['address']?.toString() ?? '',
      tnsName: json['tnsName']?.toString() ?? '',
      network: json['network']?.toString() ?? '',
    );
  }
}

class ToroPassProfile {
  final String id;
  final bool kycVerified;
  final String? kycAnchorHash;
  final ToroPassWalletProfile wallet;

  const ToroPassProfile({
    required this.id,
    required this.kycVerified,
    required this.wallet,
    this.kycAnchorHash,
  });

  factory ToroPassProfile.fromJson(Map<String, dynamic> json) {
    return ToroPassProfile(
      id: json['id']?.toString() ?? '',
      kycVerified: json['kycVerified'] == true,
      kycAnchorHash: json['kycAnchorHash']?.toString(),
      wallet: ToroPassWalletProfile.fromJson(
        json['wallet'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

class ToroPassOAuthToken {
  final String accessToken;

  const ToroPassOAuthToken({required this.accessToken});

  factory ToroPassOAuthToken.fromJson(Map<String, dynamic> json) {
    return ToroPassOAuthToken(
      accessToken: json['accessToken']?.toString() ?? '',
    );
  }
}
