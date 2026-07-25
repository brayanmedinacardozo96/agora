import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => message;
}

class ApiClient {
  final String baseUrl;
  final String endPoint;
  final Duration timeout;

  ApiClient({
    required this.baseUrl,
    required this.endPoint,
    this.timeout = const Duration(seconds: 30),
  });

  String get fullUrl => '$baseUrl$endPoint';

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('$fullUrl/$path');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(timeout);

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('No internet connection');
    } on TimeoutException {
      throw NetworkException('Connection timeout');
    } catch (e) {
      throw NetworkException('Network error: $e');
    }
  }

  Future<dynamic> get(String path, {Map<String, String>? headers}) async {
    try {
      final url = Uri.parse('$fullUrl/$path');

      final response = await http
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              ...?headers,
            },
          )
          .timeout(timeout);

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('No internet connection');
    } on TimeoutException {
      throw NetworkException('Connection timeout');
    } catch (e) {
      throw NetworkException('Network error: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      final errorBody = jsonDecode(response.body);
      throw NetworkException(
        errorBody['message'] ?? 'Server error: ${response.statusCode}',
      );
    }
  }
}
