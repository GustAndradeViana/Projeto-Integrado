import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/errors/app_exception.dart';

class QuickFreelaApiClient {
  QuickFreelaApiClient({
    required String baseUrl,
    http.Client? httpClient,
  })  : _baseUrl = _normalize(baseUrl),
        _httpClient = httpClient ?? http.Client();

  final String _baseUrl;
  final http.Client _httpClient;

  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    final response = await _httpClient
        .get(_uri(path, query))
        .timeout(const Duration(seconds: 10));
    return _decode(response);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final response = await _httpClient
        .post(
          _uri(path),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 10));
    return _decode(response);
  }

  Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    final response = await _httpClient
        .patch(
          _uri(path),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 10));
    return _decode(response);
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$_baseUrl$normalizedPath').replace(queryParameters: query);
  }

  dynamic _decode(http.Response response) {
    final body = response.body.isEmpty ? null : jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    if (body is Map<String, dynamic> && body['erro'] != null) {
      throw AppException(body['erro'].toString());
    }
    throw AppException('Erro HTTP ${response.statusCode}');
  }
}

String _normalize(String baseUrl) {
  return baseUrl.endsWith('/')
      ? baseUrl.substring(0, baseUrl.length - 1)
      : baseUrl;
}
