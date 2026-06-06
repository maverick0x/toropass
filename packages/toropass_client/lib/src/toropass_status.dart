import 'toropass_result.dart';

enum ToroPassStatusTone { success, info, warning, error }

class ToroPassStatusMessage {
  final String title;
  final String message;
  final ToroPassStatusTone tone;

  const ToroPassStatusMessage({
    required this.title,
    required this.message,
    required this.tone,
  });
}

extension ToroPassAuthResultStatusX on ToroPassAuthResult {
  ToroPassStatusMessage toStatusMessage() {
    return switch (this) {
      ToroPassAuthSuccess() => const ToroPassStatusMessage(
        title: 'Verification complete',
        message:
            'ToroPass verified the user and returned an approved identity profile.',
        tone: ToroPassStatusTone.success,
      ),
      ToroPassAuthorizationCodeReceived() => const ToroPassStatusMessage(
        title: 'Authorization received',
        message:
            'ToroPass returned an authorization code that is ready for token exchange.',
        tone: ToroPassStatusTone.info,
      ),
      ToroPassAuthDenied(:final description) => ToroPassStatusMessage(
        title: 'Access denied',
        message:
            description?.trim().isNotEmpty == true
                ? description!.trim()
                : 'The user denied the ToroPass permission request.',
        tone: ToroPassStatusTone.warning,
      ),
      ToroPassAuthCancelled() => const ToroPassStatusMessage(
        title: 'Verification cancelled',
        message:
            'The ToroPass flow ended before an authorization code was returned.',
        tone: ToroPassStatusTone.warning,
      ),
      ToroPassAuthTimeout(:final timeout) => ToroPassStatusMessage(
        title: 'Verification timed out',
        message:
            'ToroPass did not return to the app within ${timeout.inSeconds} seconds.',
        tone: ToroPassStatusTone.warning,
      ),
      ToroPassAuthTransportError(:final message) => ToroPassStatusMessage(
        title: 'Verification failed',
        message: message,
        tone: ToroPassStatusTone.error,
      ),
      ToroPassAuthStateMismatch() => const ToroPassStatusMessage(
        title: 'Verification rejected',
        message:
            'The ToroPass callback could not be trusted because the request state did not match.',
        tone: ToroPassStatusTone.error,
      ),
    };
  }
}
