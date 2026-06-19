import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'api_service.dart';

class UploadService {
  final ApiService _apiService = ApiService();

  Future<String?> uploadImage(Uint8List bytes, String filename) async {
    try {
      final token = await _apiService.getToken();
      final uri = Uri.parse('${ApiService.baseUrl}/upload');
      
      final request = http.MultipartRequest('POST', uri);
      
      // Add Authorization header
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      // Determine mimetype from filename extension
      final extension = filename.split('.').last.toLowerCase();
      String mimeType = 'image/jpeg'; // default fallback
      if (extension == 'png') {
        mimeType = 'image/png';
      } else if (extension == 'gif') {
        mimeType = 'image/gif';
      } else if (extension == 'webp') {
        mimeType = 'image/webp';
      } else if (extension == 'jpg' || extension == 'jpeg') {
        mimeType = 'image/jpeg';
      }
      
      // Add the file as bytes with explicit contentType
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
        contentType: MediaType.parse(mimeType),
      ));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['url'] as String;
      }
      
      debugPrint('Upload failed with status: ${response.statusCode}, body: ${response.body}');
      return null;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }
}
