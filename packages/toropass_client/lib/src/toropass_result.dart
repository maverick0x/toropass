import 'toropass_profile.dart';

sealed class ToroPassAuthResult {
  const ToroPassAuthResult();

  bool get isSuccess => this is ToroPassAuthSuccess;
}

class ToroPassAuthSuccess extends ToroPassAuthResult {
  final ToroPassOAuthToken token;
  final ToroPassProfile profile;

  const ToroPassAuthSuccess({required this.token, required this.profile});
}

class ToroPassAuthorizationCodeReceived extends ToroPassAuthResult {
  final String code;
  final String state;

  const ToroPassAuthorizationCodeReceived({
    required this.code,
    required this.state,
  });
}

class ToroPassAuthDenied extends ToroPassAuthResult {
  final String error;
  final String? description;

  const ToroPassAuthDenied({this.error = 'access_denied', this.description});
}

class ToroPassAuthCancelled extends ToroPassAuthResult {
  const ToroPassAuthCancelled();
}

class ToroPassAuthTimeout extends ToroPassAuthResult {
  final Duration timeout;

  const ToroPassAuthTimeout(this.timeout);
}

class ToroPassAuthTransportError extends ToroPassAuthResult {
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  const ToroPassAuthTransportError({
    required this.message,
    this.cause,
    this.stackTrace,
  });
}

class ToroPassAuthStateMismatch extends ToroPassAuthResult {
  final String expectedState;
  final String? actualState;

  const ToroPassAuthStateMismatch({
    required this.expectedState,
    this.actualState,
  });
}
