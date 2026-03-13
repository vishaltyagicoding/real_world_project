class ApiConfig {
  // Environment configuration
  // PRODUCTION: Set to false for production deployment
  static const bool isDevelopment = true;

  // Base URLs
  // Development: Local network IP for physical device testing
  static const String developmentUrl = 'http://10.29.54.46:8000/api';

  // PRODUCTION: Update with your production domain
  static const String productionUrl = 'https://your-domain.com/api';

  // Get base URL based on environment
  static String get baseUrl => isDevelopment ? developmentUrl : productionUrl;
  static String get authUrl => '$baseUrl/auth';
  static String get tasksUrl => '$baseUrl/tasks';

  // Auth endpoints
  static String get loginEndpoint => '$authUrl/login/';
  static String get registerEndpoint => '$authUrl/register/';
  static String get logoutEndpoint => '$authUrl/logout/';
  static String get refreshTokenEndpoint => '$authUrl/token/refresh/';
  static String get profileEndpoint => '$authUrl/profile/';
  static String get changePasswordEndpoint => '$authUrl/change-password/';

  // Task endpoints
  static String get tasksEndpoint => '$tasksUrl/';
  static String taskDetailEndpoint(int id) => '$tasksUrl/$id/';
  static String taskCompleteEndpoint(int id) => '$tasksUrl/$id/complete/';
  static String taskCommentEndpoint(int id) => '$tasksUrl/$id/add_comment/';
  static String get taskStatisticsEndpoint => '$tasksUrl/statistics/';

  // Headers
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Map<String, String> authHeaders(String token) {
    return {
      ...headers,
      'Authorization': 'Bearer $token',
    };
  }

  // Security: Validate HTTPS in production
  static bool isSecureConnection() {
    if (!isDevelopment && !baseUrl.startsWith('https://')) {
      throw Exception('Production must use HTTPS!');
    }
    return true;
  }
}
