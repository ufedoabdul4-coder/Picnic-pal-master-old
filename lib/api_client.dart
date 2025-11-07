import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  // Replace with your actual backend URL. For local development, use your machine's IP.
  // On Android emulator, this is typically 'http://10.0.2.2:5000'.
  static const String _baseUrl = 'http://10.20.30.14:5000'; 
  static const _storage = FlutterSecureStorage();

  // --- Token Management ---
  // In a real app, you would get this token after the user logs in.
  // For this example, we'll store a hardcoded one.
  static Future<void> setupApiToken() async {
    await _storage.write(key: 'api_token', value: 'your_secret_app_token');
  }

  static Future<String?> _getApiToken() async {
    return await _storage.read(key: 'api_token');
  }

  // --- Transcription API Call ---
  static Future<String> transcribeAudio(String audioPath) async {
    final token = await _getApiToken();
    if (token == null) {
      throw Exception('Authentication token not found.');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/transcribe'),
    );

    request.headers['x-app-token'] = token;
    request.files.add(await http.MultipartFile.fromPath('file', audioPath));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final decoded = json.decode(responseBody);
      return decoded['transcript'];
    } else {
      throw Exception('Failed to transcribe audio. Status code: ${response.statusCode}');
    }
  }
}