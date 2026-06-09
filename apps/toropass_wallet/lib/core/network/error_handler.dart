import 'dart:io';

import 'package:dio/dio.dart';

import '../config/resource/exception.dart';
import '../utilities/logger.dart';
import 'api_body_builder.dart';
import 'response_parser.dart';

class ErrorHandler {
  static Never handle(DioException error) {
    final statusCode = error.response?.statusCode;
    final method = error.requestOptions.method;
    final path = error.requestOptions.uri;
    final body = error.requestOptions.data;

    final buffer = StringBuffer()
      ..write(error.type.name.toUpperCase())
      ..write(statusCode != null ? ' [$statusCode]' : '')
      ..write(': $method $path');

    if (ApiBodyBuilder.hasBody(body)) {
      buffer.write('\nBody: ${ApiBodyBuilder.formatBody(body)}');
    }

    AppLogger.log(buffer.toString(), name: 'API-ERROR');

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        throw ApiException(message: 'Connection timeout');

      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw ApiException(message: 'Timeout');

      case DioExceptionType.badResponse:
        return _handleBadResponse(error);

      case DioExceptionType.cancel:
        throw ApiException(
          message: error.error?.toString() ?? 'Request was cancelled',
        );

      case DioExceptionType.badCertificate:
        throw ApiException(
          message: 'Bad Certificate: Unable to establish a secure connection',
        );

      case DioExceptionType.connectionError:
        if (error.error is SocketException) {
          throw ApiException(message: 'No Internet connection');
        }

        throw ApiException(
          message: error.error?.toString() ?? 'Connection refused',
        );

      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          throw ApiException(message: 'No Internet connection');
        }

        throw ApiException(
          message: error.message ?? 'An unexpected error occurred',
        );
    }
  }

  static Never _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final statusMessage = error.response?.statusMessage;
    final responseData = error.response?.data;

    final parsedError = ResponseParser.parseError(responseData);

    if (parsedError != null) {
      throw ApiException(
        path: parsedError.path,
        code: parsedError.code ?? statusCode,
        message:
            parsedError.message ??
            ApiException.messageForStatusCode(
              statusCode,
              fallback: statusMessage,
            ),
        timestamp: parsedError.timestamp,
      );
    }

    if (responseData is String && responseData.trim().isNotEmpty) {
      throw ApiException(
        code: statusCode,
        message: ApiException.messageForStatusCode(
          statusCode,
          fallback: responseData,
        ),
      );
    }

    throw ApiException(
      code: statusCode,
      message: ApiException.messageForStatusCode(
        statusCode,
        fallback: statusMessage,
      ),
    );
  }
}
