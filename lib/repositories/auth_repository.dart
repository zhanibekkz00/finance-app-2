import 'dart:convert';
import '../services/api_service.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();

  Future<void> forgotPassword(String email) async {
    final response = await _apiService.post('/auth/forgot-password', {
      'email': email,
    });
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to request password reset');
    }
  }

  Future<void> resetPassword(String email, String token, String newPassword) async {
    final response = await _apiService.post('/auth/reset-password', {
      'email': email,
      'token': token,
      'newPassword': newPassword,
    });
    
    if (response.statusCode != 200 && response.statusCode != 201) {
      String errorMessage = 'Failed to reset password';
      try {
        final body = jsonDecode(response.body);
        if (body['message'] != null) {
          errorMessage = body['message'].toString();
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }
}
