import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/device_id_provider.dart';
import '../endpoints.dart';
import '../token/token_model.dart';
import '../token/token_notifier.dart';

// For catching 401 errors and refreshing tokens: QueuedAuthInterceptor; ensures that multiple requests that fail with 401 at the same time will wait for the token refresh to complete before retrying.
class QueuedAuthInterceptor extends QueuedInterceptor {
  final Ref _ref;
  final Dio _dio;

  QueuedAuthInterceptor(this._ref, this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final deviceId = _ref.read(deviceIdProvider);

    final appSecret = dotenv.env['APP_SECRET'] ?? 'default_secret';
    final message = '$timestamp:$deviceId';
    final hmac = Hmac(sha256, utf8.encode(appSecret));
    final signature = hmac.convert(utf8.encode(message)).toString();

    options.headers['X-Timestamp'] = timestamp.toString();
    options.headers['X-Device-ID'] = deviceId;
    options.headers['X-Signature'] = signature;

    if (options.extra['useToken'] == true) {
      final token = _ref.read(tokenProvider).value?.token;

      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
        return handler.next(options);
      } else {
        // STOP THE REQUEST: If token is required but not found, reject immediately to prevent unnecessary network calls
        return handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.cancel,
            error:
                'Authentication required but no token found. Cancelling request.',
          ),
        );
      }
    }

    // For requests that don't need a token, proceed normally
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final state = _ref.read(tokenProvider);
      final notifier = _ref.read(tokenProvider.notifier);

      // Prevent infinite loops if the refresh token endpoint itself returns 401
      if (err.requestOptions.path.contains('/refresh-token')) {
        return _forceLogout(err, handler);
      }

      try {
        final refreshToken = state.value?.refreshToken;

        if (refreshToken == null) return _forceLogout(err, handler);

        final tokenDio = Dio(BaseOptions(baseUrl: ApiEndpoints.BASE_URL));

        // Re-generate HMAC for the refresh request
        final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final deviceId = _ref.read(deviceIdProvider);
        final appSecret = dotenv.env['APP_SECRET'] ?? 'default_secret';
        final message = '$timestamp:$deviceId';
        final hmac = Hmac(sha256, utf8.encode(appSecret));
        final signature = hmac.convert(utf8.encode(message)).toString();

        tokenDio.options.headers.addAll({
          'X-Timestamp': timestamp.toString(),
          'X-Device-ID': deviceId,
          'X-Signature': signature,
        });

        // Call your refresh token endpoint
        final refreshResponse = await tokenDio.post(
          ApiEndpoints.REFRESH_TOKEN,
          data: {'refreshToken': refreshToken},
        );

        if (refreshResponse.statusCode == 200 ||
            refreshResponse.statusCode == 201) {
          final responseData = refreshResponse.data;

          final List<String>? cookies = refreshResponse.headers['set-cookie'];
          if (cookies != null) {
            try {
              final cookieWithToken = cookies.firstWhere(
                (cookie) => cookie.contains('refresh_token='),
              );
              final tokenString = cookieWithToken
                  .split(';')
                  .firstWhere((e) => e.trim().startsWith('refresh_token='));

              if (responseData['data'] != null) {
                responseData['data']['refreshToken'] = tokenString.split(
                  '=',
                )[1];
              } else {
                responseData['refreshToken'] = tokenString.split('=')[1];
              }
            } catch (_) {}
          }

          final dataMap = responseData['data'] ?? responseData;
          final model = TokenModel.fromJson(dataMap);

          await notifier.updateTokens(model);

          // Update the failed request's header with the new access token
          err.requestOptions.headers['Authorization'] =
              'Bearer ${model.accessToken}';

          // Retry the original request using the original injected Dio instance
          final response = await _dio.fetch(err.requestOptions);

          // Resolve the handler with the successful response
          return handler.resolve(response);
        }
      } catch (e) {
        return _forceLogout(err, handler);
      }
    }

    return handler.next(err);
  }

  Future<void> _forceLogout(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Wipe the tokens so any subsequent requests are immediately killed in `onRequest`
    await _ref.read(tokenProvider.notifier).clearTokens();

    // Trigger UI Update (redirect to Login screen)
    // Solution: Already handled in the router by watching the token state. When tokens are cleared, the app will automatically navigate to the login screen.

    // Reject the current request so the caller knows it failed
    return handler.next(err);
  }
}
