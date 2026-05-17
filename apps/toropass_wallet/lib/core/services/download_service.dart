import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../config/resource/exception.dart';
import '../network/api_client.dart';
import '../utilities/global.dart';
import '../utilities/logger.dart';

final downloadServiceProvider = Provider<DownloadService>((ref) {
  return DownloadService(ref.watch(dioProvider));
});

class DownloadService {
  final Dio _dio;

  DownloadService(this._dio);

  static const _defaultHeader = {'Content-Type': 'application/json'};
  static final _filenameRegExp = RegExp(r'filename[^;=\n]*=([^;\n]+)');
  static final _cachePrefixRegExp = RegExp(r'^cache');

  /// Downloads a file to the device storage.
  Future<File?> download({
    required String endpoint,
    Directory? dir,
    String method = 'GET',
    bool useToken = true,
    CancelToken? cancelToken,
  }) async {
    final hasPermission = await _requestStoragePermissions();
    if (!hasPermission) {
      AppLogger.log('Storage permission denied by user.');
      return null;
    }

    final tempDir = dir ?? await _getDefaultDownloadDirectory();

    try {
      final response = await _dio.request(
        endpoint,
        options: Options(
          method: method.toUpperCase(),
          headers: Map<String, dynamic>.from(_defaultHeader),
          responseType: ResponseType.bytes,
          extra: {'useToken': useToken},
        ),
        cancelToken: cancelToken,
      );

      final fileName = _extractFileName(response.headers);
      final savePath = "${tempDir.path}/$fileName";
      final file = File(savePath);

      await file.writeAsBytes(response.data);
      return file;
    } on DioException catch (error) {
      _handleDownloadError(error);
    } catch (e, stackTrace) {
      AppLogger.log(e.toString(), error: e, trace: stackTrace);
      throw ApiServiceException(message: 'Failed to save downloaded file.');
    }
  }

  Future<bool> _requestStoragePermissions() async {
    final sdkInt = await Global.getAndroidSdkInt() ?? 30;

    // Android 13+ (SDK 33+) requires granular media permissions
    final permissions = sdkInt > 32
        ? [Permission.videos, Permission.photos]
        : [Permission.storage];

    final statuses = await permissions.request();
    return statuses.values.every((status) => status.isGranted);
  }

  Future<Directory> _getDefaultDownloadDirectory() async {
    if (Platform.isIOS) {
      return await getDownloadsDirectory() ??
          await getApplicationDocumentsDirectory();
    } else {
      final dir = Directory("/storage/emulated/0/Download/");
      return await dir.exists()
          ? dir
          : await getApplicationDocumentsDirectory();
    }
  }

  String _extractFileName(Headers headers) {
    String fileName = 'downloaded_file';
    final contentDisposition = headers.value('content-disposition');
    final contentType = headers.value('content-type');

    if (contentDisposition != null &&
        contentDisposition.contains('filename=')) {
      final match = _filenameRegExp.firstMatch(contentDisposition);
      if (match != null) {
        fileName =
            match.group(1)?.replaceAll(RegExp(r'''["\s']'''), '') ?? fileName;
      }
    }

    fileName = fileName.replaceAll(_cachePrefixRegExp, '');

    if (contentType != null) {
      if (contentType.contains('application/pdf') &&
          !fileName.endsWith('.pdf')) {
        fileName += '.pdf';
      } else if (contentType.contains('image/')) {
        final ext = contentType.split('/').last;
        if (!fileName.endsWith('.$ext')) fileName += '.$ext';
      }
    }

    return fileName;
  }

  Never _handleDownloadError(DioException error) {
    if (error.type == DioExceptionType.cancel) {
      throw ApiServiceException(message: 'Download was cancelled by user');
    }

    AppLogger.log(error.message ?? 'Unknown Dio Download Error', error: error);
    throw ApiServiceException(message: 'Failed to download file from server');
  }
}
