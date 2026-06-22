import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Поменяйте на true и укажите ваш URL на Render.com перед сборкой/деплоем приложения
  static const bool isProduction = true;
  static const String productionUrl = 'https://my-finance-app-backend.onrender.com/api';

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
        // Use the local network IP so the physical device can connect over Wi-Fi
        return 'http://192.168.1.66:3000/api';
      }
    } catch (_) {}
    // Fallback to local network IP
    return 'http://192.168.1.66:3000/api';
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
      final scheme = baseUri.scheme;

      // Replace localhost, 10.0.2.2, and any 192.168.x.x IPs
      final ipPattern = RegExp(r'https?:\/\/(localhost|127\.0\.0\.1|10\.0\.2\.2|192\.168\.\d+\.\d+):\d+');
      
      final sanitizedBody = response.body.replaceAllMapped(ipPattern, (match) {
        return '$scheme://$hostPort';
      });

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
