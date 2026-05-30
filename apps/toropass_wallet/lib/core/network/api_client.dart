import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../config/resource/exception.dart';
import '../config/resource/response.dart';
import '../utilities/enum/http_request_type.dart';
import '../utilities/logger.dart';
import 'endpoints.dart';
import 'interceptor/auth_interceptor.dart';
import 'interceptor/security_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.BASE_URL,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final context = SecurityContext(withTrustedRoots: false);
      // TODO: Replace with your actual certificate bytes
      // final certBytes = <int>[];
      // context.setTrustedCertificatesBytes(certBytes);

      final client = HttpClient(context: context);

      // NEVER — not even in debug
      client.badCertificateCallback = (cert, host, port) => false;
      return client;
    },
  );

  // Inject Interceptors
  dio.interceptors.addAll([
    SecurityInterceptor(ref),
    QueuedAuthInterceptor(ref, dio),
    PrettyDioLogger(
      responseBody: true,
      requestBody: true,
      enabled: kDebugMode,
      filter: (options, args) {
        if (options.extra['silent'] == true) {
          return false;
        }
        return true;
      },
    ),
  ]);
  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiClient(dio);
});

class ApiClient {
  final Dio _dio;
  ApiClient(this._dio);

  static const _defaultHeader = {'Content-Type': 'application/json'};

  Future<SuccessResponse> get({
    required String endpoint,
    Map<String, dynamic>? queryParameters,
    bool useToken = true,
    bool silent = true,
    CancelToken? cancelToken,
  }) async {
    return _call(
      endpoint: endpoint,
      type: RequestType.GET,
      queryParameters: queryParameters,
      useToken: useToken,
      silent: silent,
      cancelToken: cancelToken,
    );
  }

  Future<SuccessResponse> post({
    required String endpoint,
    required Map<String, dynamic> body,
    bool useToken = true,
    bool silent = true,
    CancelToken? cancelToken,
  }) async {
    return _call(
      endpoint: endpoint,
      type: RequestType.POST,
      data: body,
      silent: silent,
      useToken: useToken,
      cancelToken: cancelToken,
    );
  }

  Future<SuccessResponse> put({
    required String endpoint,
    Object? body,
    bool useToken = true,
    bool silent = true,
    CancelToken? cancelToken,
  }) async {
    return _call(
      endpoint: endpoint,
      type: RequestType.PUT,
      data: body,
      silent: silent,
      useToken: useToken,
      cancelToken: cancelToken,
    );
  }

  Future<SuccessResponse> patch({
    required String endpoint,
    Object? body,
    Map<String, dynamic>? queryParameters,
    bool useToken = true,
    bool silent = true,
    CancelToken? cancelToken,
  }) async {
    return _call(
      endpoint: endpoint,
      type: RequestType.PATCH,
      data: body,
      silent: silent,
      queryParameters: queryParameters,
      useToken: useToken,
      cancelToken: cancelToken,
    );
  }

  Future<SuccessResponse> delete({
    required String endpoint,
    Object? body,
    Map<String, dynamic>? queryParameters,
    bool useToken = true,
    bool silent = true,
    CancelToken? cancelToken,
  }) async {
    return _call(
      endpoint: endpoint,
      type: RequestType.DELETE,
      data: body,
      silent: silent,
      queryParameters: queryParameters,
      useToken: useToken,
      cancelToken: cancelToken,
    );
  }

  /// Centralized HTTP request handler
  Future<SuccessResponse> _call({
    required String endpoint,
    required RequestType type,
    Object? data,
    Map<String, dynamic>? queryParameters,
    required bool useToken,
    required bool silent,
    CancelToken? cancelToken,
  }) async {
    try {
      final options = Options(
        method: type.name,
        headers: Map<String, dynamic>.from(_defaultHeader),
        extra: {'useToken': useToken, 'silent': silent},
      );

      // Handle multipart/form-data if there are files in the data
      Object? body;
      if (data is Map<String, dynamic>) {
        bool containsFiles = false;
        data.forEach((key, value) {
          if (value is MultipartFile) {
            containsFiles = true;
          } else if (value is List && value.any((e) => e is MultipartFile)) {
            containsFiles = true;
          }
        });

        if (containsFiles) {
          body = FormData.fromMap(data, ListFormat.multi);
        } else {
          body = data;
        }
      } else {
        body = data;
      }

      if (!silent) {
        // Log the request details, including body and query parameters
        AppLogger.log(
          "Making ${type.name} request to $endpoint with \nBody: ${body is FormData ? body.fields : body}\nQuery: $queryParameters",
          name: "API-CLIENT",
        );
      }

      final response = await _dio.request(
        endpoint,
        data: body,
        queryParameters: queryParameters,
        options: options,
      );

      return SuccessResponse.fromJson(response.data);
    } on DioException catch (error) {
      _handleDioError(error);
    } catch (e, stackTrace) {
      AppLogger.log(e.toString(), error: e, trace: stackTrace);
      throw ApiServiceException(message: e.toString());
    }
  }

  static Never _handleDioError(DioException error) {
    AppLogger.log(error.message ?? 'Unknown Error', error: error);

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        throw ApiServiceException(message: 'Connection timeout');

      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw ApiServiceException(message: 'Timeout');

      case DioExceptionType.badResponse:
        final data = error.response?.data as Map<String, dynamic>? ?? {};
        final response = ErrorResponse.fromJson(data);

        throw ApiServiceException(
          path: response.path,
          code: response.code,
          message: response.message,
          timestamp: response.timestamp,
        );

      case DioExceptionType.cancel:
        throw ApiServiceException(message: 'Request was cancelled');

      case DioExceptionType.badCertificate:
        throw ApiServiceException(
          message: 'Bad Certificate: Unable to establish a secure connection',
        );

      case DioExceptionType.connectionError:
        throw ApiServiceException(message: 'Connection Refused');

      default:
        if (error.error is SocketException) {
          throw ApiServiceException(message: 'No Internet connection');
        }
        throw ApiServiceException(
          message: error.message ?? 'An unexpected error occurred',
        );
    }
  }
}
