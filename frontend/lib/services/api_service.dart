import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'storage_service.dart';

class ApiService {
  // Validate secure connection on initialization
  static bool _initialized = false;

  static void _ensureInitialized() {
    if (!_initialized) {
      ApiConfig.isSecureConnection();
      _initialized = true;
    }
  }

  static Future<Map<String, dynamic>> _handleResponse(http.Response response,
      {bool isAuthRequest = false}) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = response.body;
      if (body.isEmpty) {
        return {};
      }
      try {
        final decoded = json.decode(body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        throw Exception('Invalid response format');
      } catch (e) {
        throw Exception('Failed to parse response: $e');
      }
    } else if (response.statusCode == 401) {
      // For login/register requests, don't try to refresh token
      if (isAuthRequest) {
        try {
          final error = json.decode(response.body);
          final message =
              error['detail'] ?? error['message'] ?? 'Invalid credentials';
          throw Exception(message);
        } catch (e) {
          if (e.toString().contains('Exception:')) rethrow;
          throw Exception('Invalid credentials');
        }
      }

      // For other requests, try to refresh token
      final refreshed = await _refreshToken();
      if (!refreshed) {
        throw Exception('Session expired. Please login again.');
      }
      throw Exception('Token refreshed. Please retry.');
    } else {
      try {
        final error = json.decode(response.body);
        final message = error['detail'] ?? error['message'] ?? error.toString();
        throw Exception(message);
      } catch (e) {
        if (e.toString().contains('Exception:')) rethrow;
        throw Exception('Request failed with status ${response.statusCode}');
      }
    }
  }

  static Future<bool> _refreshToken() async {
    try {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse(ApiConfig.refreshTokenEndpoint),
        headers: ApiConfig.headers,
        body: json.encode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await StorageService.saveTokens(data['access'], refreshToken);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await StorageService.getAccessToken();
    return token != null ? ApiConfig.authHeaders(token) : ApiConfig.headers;
  }

  // GET request
  static Future<Map<String, dynamic>> get(String url) async {
    _ensureInitialized();
    final headers = await _getAuthHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);
    return _handleResponse(response);
  }

  // POST request
  static Future<Map<String, dynamic>> post(
      String url, Map<String, dynamic> body,
      {bool isAuthRequest = false}) async {
    _ensureInitialized();
    final headers = await _getAuthHeaders();
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(body),
    );
    return _handleResponse(response, isAuthRequest: isAuthRequest);
  }

  // PUT request
  static Future<Map<String, dynamic>> put(
      String url, Map<String, dynamic> body) async {
    _ensureInitialized();
    final headers = await _getAuthHeaders();
    final response = await http.put(
      Uri.parse(url),
      headers: headers,
      body: json.encode(body),
    );
    return _handleResponse(response);
  }

  // DELETE request
  static Future<void> delete(String url) async {
    _ensureInitialized();
    final headers = await _getAuthHeaders();
    final response = await http.delete(Uri.parse(url), headers: headers);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to delete');
    }
  }
}
