import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'api_client.dart';
import 'endpoints.dart';
import 'interceptor/auth_interceptor.dart';
import 'interceptor/security_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.BASE_URL,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // dio.httpClientAdapter = IOHttpClientAdapter(
  //   createHttpClient: () {
  //     final context = SecurityContext(withTrustedRoots: false);
  //     TODO: Replace with your actual certificate bytes
  //     final certBytes = <int>[];
  //     context.setTrustedCertificatesBytes(certBytes);

  //     final client = HttpClient(context: context);

  //     // NEVER — not even in debug
  //     client.badCertificateCallback = (cert, host, port) => false;
  //     return client;
  //   },
  // );

  dio.interceptors.addAll([
    SecurityInterceptor(ref),
    QueuedAuthInterceptor(ref, dio),
    PrettyDioLogger(
      responseBody: true,
      requestBody: true,
      enabled: kDebugMode,
      filter: (options, args) {
        return options.extra['silent'] != true;
      },
    ),
  ]);

  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});
