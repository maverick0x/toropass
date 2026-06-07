import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'toropass_authorization_request.dart';
import 'toropass_callback_listener.dart';
import 'toropass_client_config.dart';
import 'toropass_exception.dart';
import 'toropass_http_client.dart';
import 'toropass_profile.dart';
import 'toropass_result.dart';
import 'toropass_wallet_launcher.dart';

class ToroPassClient {
  final ToroPassClientConfig config;
  final ToroPassWalletLauncher _walletLauncher;
  final ToroPassCallbackListener _callbackListener;
  final ToroPassHttpClient _httpClient;

  ToroPassClient({
    required this.config,
    ToroPassWalletLauncher? walletLauncher,
    ToroPassCallbackListener? callbackListener,
    ToroPassHttpClient? httpClient,
  })  : _walletLauncher =
            walletLauncher ?? const UrlLauncherToroPassWalletLauncher(),
        _callbackListener =
            callbackListener ?? AppLinksToroPassCallbackListener(),
        _httpClient = httpClient ?? HttpToroPassClient();

  ToroPassAuthorizationRequest createAuthorizationRequest({String? state}) {
    final requestState = _requireState(state ?? _generateState());
    final query = <String, String>{
      'client_id': config.clientId,
      'redirect_uri': config.redirectUri.toString(),
      'scopes': config.scopeValues.join(','),
      'state': requestState,
      'app_name': config.appName,
    };

    return ToroPassAuthorizationRequest(
      launchUri: config.walletLaunchUri.replace(queryParameters: query),
      state: requestState,
      clientId: config.clientId,
      redirectUri: config.redirectUri,
      scopes: config.scopes,
      appName: config.appName,
    );
  }

  Future<bool> canLaunchWallet({ToroPassAuthorizationRequest? request}) {
    return _walletLauncher.canLaunch(
      request?.launchUri ?? createAuthorizationRequest().launchUri,
    );
  }

  Future<ToroPassAuthorizationRequest?> launchWallet({
    String? state,
  }) async {
    final request = createAuthorizationRequest(state: state);
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

  Future<ToroPassAuthResult> verifyIdentity() async {
    final request = await launchWallet();
    if (request == null) {
      return const ToroPassAuthTransportError(
        message: 'ToroPass Wallet is not installed or cannot be opened.',
      );
    }

    final callbackResult = await waitForCallback(request);
    if (callbackResult is! ToroPassAuthorizationCodeReceived) {
      return callbackResult;
    }

    try {
      final session = await exchangeAuthorizationCode(
        code: callbackResult.code,
      );
      return ToroPassAuthSuccess(
        token: session.token,
        profile: session.profile,
      );
    } catch (error, stackTrace) {
      return _transportError(error, stackTrace);
    }
  }

  Future<ToroPassOAuthSession> exchangeAuthorizationCode({
    required String code,
    String? clientSecret,
  }) async {
    final body = <String, dynamic>{
      'client_id': config.clientId,
      'code': _requireCode(code),
      'redirect_uri': config.redirectUri.toString(),
      if (clientSecret?.trim().isNotEmpty == true)
        'client_secret': clientSecret!.trim(),
    };

    final response = await _httpClient.postJson(
      _endpoint('/oauth/token'),
      body: body,
    );

    return ToroPassOAuthSession.fromJson(_data(response));
  }

  Future<ToroPassProfile> fetchProfile({required String accessToken}) async {
    final token = _requireAccessToken(accessToken);
    final response = await _httpClient.getJson(
      _endpoint('/oauth/profile'),
      headers: {'Authorization': 'Bearer $token'},
    );

    return ToroPassProfile.fromJson(_data(response));
  }

  static Map<String, dynamic> _data(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is Map<String, dynamic>) return data;
    return const {};
  }

  Uri _endpoint(String path) {
    final basePath = config.issuerBaseUrl.path.endsWith('/')
        ? config.issuerBaseUrl.path.substring(
            0,
            config.issuerBaseUrl.path.length - 1,
          )
        : config.issuerBaseUrl.path;

    return config.issuerBaseUrl.replace(path: '$basePath$path');
  }

  static String _requireCode(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(
        value,
        'code',
        'Authorization code is required.',
      );
    }
    return trimmed;
  }

  static String _requireAccessToken(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(
        value,
        'accessToken',
        'Access token is required.',
      );
    }
    return trimmed;
  }

  static ToroPassAuthTransportError _transportError(
    Object error,
    StackTrace stackTrace,
  ) {
    return ToroPassAuthTransportError(
      message: error is ToroPassException
          ? error.message
          : 'ToroPass verification failed.',
      cause: error,
      stackTrace: stackTrace,
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
