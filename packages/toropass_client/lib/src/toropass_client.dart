import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'toropass_authorization_request.dart';
import 'toropass_callback_listener.dart';
import 'toropass_client_config.dart';
import 'toropass_profile.dart';
import 'toropass_result.dart';
import 'toropass_wallet_launcher.dart';

class ToroPassClient {
  final ToroPassClientConfig config;
  final ToroPassWalletLauncher _walletLauncher;
  final ToroPassCallbackListener _callbackListener;

  ToroPassClient({
    required this.config,
    ToroPassWalletLauncher? walletLauncher,
    ToroPassCallbackListener? callbackListener,
  }) : _walletLauncher =
           walletLauncher ?? const UrlLauncherToroPassWalletLauncher(),
       _callbackListener =
           callbackListener ?? AppLinksToroPassCallbackListener();

  ToroPassAuthorizationRequest createAuthorizationRequest({
    String? appName,
    String? state,
  }) {
    final requestState = _requireState(state ?? _generateState());
    final query = <String, String>{
      'client_id': config.clientId,
      'redirect_uri': config.redirectUri.toString(),
      'scopes': config.scopeValues.join(','),
      'state': requestState,
      if (appName?.trim().isNotEmpty == true) 'app_name': appName!.trim(),
    };

    return ToroPassAuthorizationRequest(
      launchUri: config.walletLaunchUri.replace(queryParameters: query),
      state: requestState,
      clientId: config.clientId,
      redirectUri: config.redirectUri,
      scopes: config.scopes,
      appName: appName?.trim().isEmpty == true ? null : appName?.trim(),
    );
  }

  Future<bool> canLaunchWallet({ToroPassAuthorizationRequest? request}) {
    return _walletLauncher.canLaunch(
      request?.launchUri ?? createAuthorizationRequest().launchUri,
    );
  }

  Future<ToroPassAuthorizationRequest?> launchWallet({
    String? appName,
    String? state,
  }) async {
    final request = createAuthorizationRequest(appName: appName, state: state);
    final isAvailable = await _walletLauncher.canLaunch(request.launchUri);
    if (!isAvailable) return null;

    final launched = await _walletLauncher.launch(request.launchUri);
    return launched ? request : null;
  }

  Future<ToroPassAuthResult> waitForCallback(
    ToroPassAuthorizationRequest request, {
    Duration? timeout,
  }) async {
    final waitDuration = timeout ?? config.callbackTimeout;

    try {
      final callbackUri = await _callbackListener.uriStream
          .where((uri) => _matchesRedirectUri(uri, request.redirectUri))
          .first
          .timeout(waitDuration);

      return parseCallbackUri(callbackUri, expectedState: request.state);
    } on TimeoutException {
      return ToroPassAuthTimeout(waitDuration);
    } catch (error, stackTrace) {
      return ToroPassAuthTransportError(
        message: 'Unable to receive the ToroPass callback.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  ToroPassAuthResult parseCallbackUri(
    Uri uri, {
    required String expectedState,
  }) {
    final actualState = uri.queryParameters['state'];
    if (actualState != expectedState) {
      return ToroPassAuthStateMismatch(
        expectedState: expectedState,
        actualState: actualState,
      );
    }

    final error = uri.queryParameters['error'];
    if (error != null && error.isNotEmpty) {
      return ToroPassAuthDenied(
        error: error,
        description: uri.queryParameters['error_description'],
      );
    }

    final code = uri.queryParameters['code'];
    if (code != null && code.isNotEmpty) {
      return ToroPassAuthorizationCodeReceived(
        code: code,
        state: actualState ?? '',
      );
    }

    return const ToroPassAuthCancelled();
  }

  Future<ToroPassAuthResult> verifyIdentity() {
    throw UnimplementedError(
      'verifyIdentity will be implemented in the wallet launch and OAuth phases.',
    );
  }

  Future<ToroPassOAuthToken> exchangeAuthorizationCode({required String code}) {
    throw UnimplementedError(
      'exchangeAuthorizationCode will be implemented with /oauth/token.',
    );
  }

  Future<ToroPassProfile> fetchProfile({required String accessToken}) {
    throw UnimplementedError(
      'fetchProfile will be implemented with /oauth/profile.',
    );
  }

  static String _generateState() {
    final bytes = Uint8List(24);
    final random = Random.secure();
    for (var i = 0; i < bytes.length; i++) {
      bytes[i] = random.nextInt(256);
    }
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  static String _requireState(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(value, 'state', 'State is required.');
    }
    return trimmed;
  }

  static bool _matchesRedirectUri(Uri uri, Uri redirectUri) {
    return uri.scheme == redirectUri.scheme &&
        uri.host == redirectUri.host &&
        uri.path == redirectUri.path;
  }
}
