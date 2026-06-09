import 'package:dio/dio.dart';

import '../config/resource/response.dart';
import '../utilities/enum/http_request_type.dart';
import 'request_handler.dart';

class ApiClient {
  final RequestHandler _requestHandler;

  ApiClient(Dio dio) : _requestHandler = RequestHandler(dio);

  Future<SuccessResponse> get({
    required String endpoint,
    Map<String, dynamic>? queryParameters,
    bool useToken = true,
    bool silent = true,
    CancelToken? cancelToken,
  }) {
    return _requestHandler.call(
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
  }) {
    return _requestHandler.call(
      endpoint: endpoint,
      type: RequestType.POST,
      data: body,
      useToken: useToken,
      silent: silent,
      cancelToken: cancelToken,
    );
  }

  Future<SuccessResponse> put({
    required String endpoint,
    Object? body,
    bool useToken = true,
    bool silent = true,
    CancelToken? cancelToken,
  }) {
    return _requestHandler.call(
      endpoint: endpoint,
      type: RequestType.PUT,
      data: body,
      useToken: useToken,
      silent: silent,
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
  }) {
    return _requestHandler.call(
      endpoint: endpoint,
      type: RequestType.PATCH,
      data: body,
      queryParameters: queryParameters,
      useToken: useToken,
      silent: silent,
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
  }) {
    return _requestHandler.call(
      endpoint: endpoint,
      type: RequestType.DELETE,
      data: body,
      queryParameters: queryParameters,
      useToken: useToken,
      silent: silent,
      cancelToken: cancelToken,
    );
  }
}
