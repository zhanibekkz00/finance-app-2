import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Поменяйте на true и укажите ваш URL на Render.com перед сборкой/деплоем приложения
  static const bool isProduction = false;
  static const String productionUrl = 'https://YOUR-APP-NAME.onrender.com/api';

  static String get baseUrl {
    if (isProduction) {
      return productionUrl;
    }
    // Determine proper backend URL based on platform.
    if (kIsWeb) {
      // Web runs on the same machine as the dev server.
      return 'http://localhost:3000/api';
    }
    try {
      if (Platform.isAndroid) {
        // Since USB debugging is active, we use adb reverse tcp:3000 tcp:3000
        // and connect to localhost / 127.0.0.1.
        return 'http://127.0.0.1:3000/api';
      }
    } catch (_) {}
    // Fallback to localhost.
    return 'http://127.0.0.1:3000/api';
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  http.Response _sanitizeResponse(http.Response response) {
    try {
      final baseUri = Uri.parse(baseUrl);
      final hostPort = baseUri.port == 80 || baseUri.port == 443
          ? baseUri.host
          : "${baseUri.host}:${baseUri.port}";

      final sanitizedBody = response.body
          .replaceAll('localhost:3000', hostPort)
          .replaceAll('127.0.0.1:3000', hostPort)
          .replaceAll('10.0.2.2:3000', hostPort);

      return http.Response(
        sanitizedBody,
        response.statusCode,
        headers: response.headers,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase,
        request: response.request,
      );
    } catch (_) {
      return response;
    }
  }

  Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$baseUrl$endpoint'), headers: headers);
    return _sanitizeResponse(response);
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
    return _sanitizeResponse(response);
  }

  Future<http.Response> patch(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    final response = await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
    return _sanitizeResponse(response);
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
    return _sanitizeResponse(response);
  }

  Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeaders();
    final response = await http.delete(Uri.parse('$baseUrl$endpoint'), headers: headers);
    return _sanitizeResponse(response);
  }
}
