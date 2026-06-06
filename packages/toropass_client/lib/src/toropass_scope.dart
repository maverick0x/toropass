enum ToroPassScope {
  kycStatus('kyc_status'),
  wallet('wallet');

  const ToroPassScope(this.value);

  final String value;

  static ToroPassScope? fromValue(String value) {
    for (final scope in values) {
      if (scope.value == value) return scope;
    }
    return null;
  }
}
