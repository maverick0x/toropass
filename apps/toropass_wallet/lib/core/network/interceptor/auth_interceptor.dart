import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/hmac_provider.dart';
import '../endpoints.dart';
import '../token/token_model.dart';
import '../token/token_notifier.dart';

class QueuedAuthInterceptor extends QueuedInterceptor {
  final Ref _ref;
  final Dio _dio;

  QueuedAuthInterceptor(this._ref, this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final hmac = _ref.read(hmacProvider)();

    options.headers['X-Device-ID'] = hmac.deviceId;
    options.headers['X-Timestamp'] = hmac.timestamp;
    options.headers['X-Signature'] = hmac.signature;
    options.headers['x-api-key'] = dotenv.env['APP_API_KEY'] ?? '';

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
      if (err.requestOptions.path.contains(ApiEndpoints.WALLET_REFRESH)) {
        return _forceLogout(err, handler);
      }

      try {
        final refreshToken = state.value?.refreshToken;

        if (refreshToken == null) return _forceLogout(err, handler);

        final tokenDio = Dio(BaseOptions(baseUrl: ApiEndpoints.BASE_URL));

        // Re-generate HMAC for the refresh request
        final hmac = _ref.read(hmacProvider)();
        tokenDio.options.headers.addAll({
          'x-api-key': dotenv.env['APP_API_KEY'] ?? '',
          'X-Timestamp': hmac.timestamp,
          'X-Device-ID': hmac.deviceId,
          'X-Signature': hmac.signature,
        });

        // Call your refresh token endpoint
        final refreshResponse = await tokenDio.post(
          ApiEndpoints.WALLET_REFRESH,
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
