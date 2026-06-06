import 'dart:convert';

import 'package:http/http.dart' as http;

import 'toropass_exception.dart';

abstract class ToroPassHttpClient {
  Future<Map<String, dynamic>> postJson(
    Uri uri, {
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> getJson(Uri uri, {Map<String, String>? headers});
}

class HttpToroPassClient implements ToroPassHttpClient {
  final http.Client _client;

  HttpToroPassClient({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<Map<String, dynamic>> postJson(
    Uri uri, {
    required Map<String, dynamic> body,
  }) async {
    final response = await _client.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _decodeResponse(response);
  }

  @override
  Future<Map<String, dynamic>> getJson(
    Uri uri, {
    Map<String, String>? headers,
  }) async {
    final response = await _client.get(uri, headers: headers);
    return _decodeResponse(response);
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final decoded = response.body.isEmpty
        ? const <String, dynamic>{}
        : jsonDecode(response.body);
    final body = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final message = body['message']?.toString();
    if (response.statusCode == 401) {
      throw ToroPassTokenInvalidException(
        statusCode: response.statusCode,
        message: message ?? 'ToroPass access token is expired or invalid.',
      );
    }

    throw ToroPassException(
      statusCode: response.statusCode,
      message: message ?? 'ToroPass request failed.',
    );
  }
}
