import '../config/api_config.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await ApiService.post(
      ApiConfig.loginEndpoint,
      {
        'email': email,
        'password': password,
      },
      isAuthRequest: true,
    );

    if (response['access'] == null || response['refresh'] == null) {
      throw Exception('Invalid login response from server');
    }

    await StorageService.saveTokens(response['access'], response['refresh']);
    return response;
  }

  static Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
    required String password2,
    String? firstName,
    String? lastName,
  }) async {
    final response = await ApiService.post(
      ApiConfig.registerEndpoint,
      {
        'email': email,
        'username': username,
        'password': password,
        'password2': password2,
        'first_name': firstName ?? '',
        'last_name': lastName ?? '',
      },
      isAuthRequest: true,
    );

    await StorageService.saveTokens(response['access'], response['refresh']);
    return response;
  }

  static Future<void> logout() async {
    try {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken != null) {
        try {
          await ApiService.post(ApiConfig.logoutEndpoint, {
            'refresh': refreshToken,
          });
        } catch (e) {
          // Log the error but don't fail - proceed to clear local tokens
          print('Logout API error: $e');
        }
      }
    } finally {
      // Always clear local tokens regardless of API response
      await StorageService.deleteTokens();
    }
  }

  static Future<User> getProfile() async {
    final response = await ApiService.get(ApiConfig.profileEndpoint);
    return User.fromJson(response);
  }

  static Future<User> updateProfile(Map<String, dynamic> data) async {
    final response = await ApiService.put(ApiConfig.profileEndpoint, data);
    return User.fromJson(response);
  }

  static Future<void> changePassword(
    String oldPassword,
    String newPassword,
  ) async {
    await ApiService.post(ApiConfig.changePasswordEndpoint, {
      'old_password': oldPassword,
      'new_password': newPassword,
    });
  }

  static Future<bool> isLoggedIn() async {
    return await StorageService.hasToken();
  }
}
