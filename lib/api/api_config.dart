import 'package:shared_preferences/shared_preferences.dart';

/// API Configuration
/// Centralized configuration for API base URL and settings
/// Base URL can be overridden from SharedPreferences with key "baseUrl"
class ApiConfig {
  // Default Base URL - Used if not set in SharedPreferences
  static const String defaultBaseUrl = 'http://localhost:8080';
  
  // API version prefix (if your API uses versioning)
  // Set to empty string if no version prefix needed
  static const String apiPrefix = '';
  
  // Get base URL from SharedPreferences or use default
  static Future<String> getBaseUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUrl = prefs.getString('baseUrl');
      return storedUrl ?? defaultBaseUrl;
    } catch (e) {
      return defaultBaseUrl;
    }
  }
  
  // Synchronous getter for base URL (uses default if async not available)
  // Note: For ApiClient initialization, use getBaseUrl() async method
  static String get baseUrl => defaultBaseUrl;
  
  // Full API base URL (async version - preferred)
  static Future<String> get apiBaseUrl async {
    final url = await getBaseUrl();
    return apiPrefix.isEmpty ? url : '$url$apiPrefix';
  }
  
  // Timeout durations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}

