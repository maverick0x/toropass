import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../token/token_notifier.dart';

class SecurityInterceptor extends Interceptor {
  final Ref _ref;

  SecurityInterceptor(this._ref);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Detect if a proxy is configured on the device network
    final proxy = HttpClient.findProxyFromEnvironment(options.uri);

    if (proxy != 'DIRECT') {
      // Proxy detected: Clear tokens (logout) and abort request
      await _ref.read(tokenProvider.notifier).clearTokens();

      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.cancel,
          error:
              'Security Exception: Proxy detected. Traffic interception blocked.',
        ),
      );
    }

    return handler.next(options);
  }
}
