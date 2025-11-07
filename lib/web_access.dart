import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class WebAccessService {
  // Replace with your actual backend URL. For local dev, use your machine's IP.
  // Android emulator: 'http://10.0.2.2:5000'
  static const String _baseUrl = 'http://10.20.30.14:5000';
  static const _storage = FlutterSecureStorage();

  // --- Token Management ---
  static Future<void> setupApiToken() async {
    // In a real app, this token would come from a login response.
    await _storage.write(key: 'web_api_token', value: 'your_secure_flutter_app_token');
  }

  static Future<String?> _getApiToken() async {
    return await _storage.read(key: 'web_api_token');
  }

  // --- Search API Call ---
  static Future<String> search(String query) async {
    return _makeRequest('/search', {'q': query}, 'summary');
  }

  // --- Weather API Call ---
  static Future<String> getWeather(String city) async {
    return _makeRequest('/weather', {'city': city}, 'weather');
  }

  // --- Generic Request Handler ---
  static Future<String> _makeRequest(String endpoint, Map<String, String> params, String responseKey) async {
    final token = await _getApiToken();
    if (token == null) {
      throw Exception('Authentication token not found for web service.');
    }

    final uri = Uri.parse('$_baseUrl$endpoint').replace(queryParameters: params);
    final response = await http.get(
      uri,
      headers: {'x-app-token': token},
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return decoded[responseKey] ?? 'No content found.';
    } else {
      throw Exception('Failed to fetch data from $endpoint. Status: ${response.statusCode}');
    }
  }
}