import 'package:dio/dio.dart';

class ApiBody {
  static Object? build(Object? data) {
    if (data is! Map<String, dynamic>) {
      return data;
    }

    final containsFiles = data.values.any((value) {
      if (value is MultipartFile) return true;
      if (value is List && value.any((e) => e is MultipartFile)) return true;
      return false;
    });

    if (containsFiles) {
      return FormData.fromMap(data, ListFormat.multi);
    }

    return data;
  }

  static bool hasBody(Object? body) {
    if (body == null) return false;

    if (body is FormData) {
      return body.fields.isNotEmpty || body.files.isNotEmpty;
    }

    if (body is Map) {
      return body.isNotEmpty;
    }

    if (body is Iterable) {
      return body.isNotEmpty;
    }

    if (body is String) {
      return body.trim().isNotEmpty;
    }

    return true;
  }

  static Object formatBody(Object body) {
    if (body is FormData) {
      return {
        'fields': Map.fromEntries(body.fields),
        'files': body.files.map((file) {
          return {
            'field': file.key,
            'filename': file.value.filename,
            'contentType': file.value.contentType.toString(),
            'length': file.value.length,
          };
        }).toList(),
      };
    }

    return body;
  }
}
