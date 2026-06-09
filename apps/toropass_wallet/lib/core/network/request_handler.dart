import 'package:dio/dio.dart';

import '../config/resource/exception.dart';
import '../config/resource/response.dart';
import '../utilities/enum/http_request_type.dart';
import '../utilities/logger.dart';
import 'api_body.dart';
import 'error_handler.dart';
import 'response_parser.dart';

class RequestHandler {
  final Dio dio;

  RequestHandler(this.dio);

  Future<SuccessResponse> call({
    required String endpoint,
    required RequestType type,
    Object? data,
    Map<String, dynamic>? queryParameters,
    required bool useToken,
    required bool silent,
    CancelToken? cancelToken,
  }) async {
    try {
      final body = ApiBody.build(data);

      final options = Options(
        method: type.name,
        extra: {'useToken': useToken, 'silent': silent},
      );

      final response = await dio.request(
        endpoint,
        data: body,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      return ResponseParser.parseSuccess(response.data);
    } on DioException catch (error) {
      ErrorHandler.handle(error);
    } catch (e, stackTrace) {
      AppLogger.log(e.toString(), error: e, trace: stackTrace);

      throw ApiException(message: e.toString());
    }
  }
}
