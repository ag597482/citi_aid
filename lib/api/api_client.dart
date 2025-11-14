import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_response.dart';
import 'api_config.dart';

/// Common API Client for making HTTP requests using Dio
/// This is a reusable framework that handles GET, POST, PUT, DELETE requests
/// Includes file upload support, interceptors, and better error handling
class ApiClient {
  // Singleton instance
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl, // Will use default, updated dynamically
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _setupInterceptors();
    
    // Initialize base URL from SharedPreferences
    _initializeBaseUrl();
  }

  late Dio _dio;

  /// Initialize base URL from SharedPreferences
  Future<void> _initializeBaseUrl() async {
    final url = await ApiConfig.getBaseUrl();
    _dio.options.baseUrl = url;
  }

  /// Update base URL dynamically
  /// Call this when baseUrl is changed in SharedPreferences
  Future<void> updateBaseUrl() async {
    final url = await ApiConfig.getBaseUrl();
    _dio.options.baseUrl = url;
  }

  /// Setup interceptors for auth and logging
  void _setupInterceptors() {
    // Auth interceptor - automatically adds token to requests
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          try {
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString('auth_token');
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (e) {
            // Token not available, continue without it
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          // Handle 401 unauthorized - clear token and redirect to login
          if (error.response?.statusCode == 401) {
            clearAuthToken();
          }
          return handler.next(error);
        },
      ),
    );

    // Logging interceptor (only in debug mode)
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
      ),
    );
  }

  /// Handle Dio response and convert to ApiResponse
  ApiResponse<T> _handleResponse<T>(Response response, T Function(dynamic)? fromJson) {
    try {
      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      if (statusCode >= 200 && statusCode < 300) {
        // Success
        final data = fromJson != null && body != null 
            ? fromJson(body) 
            : body as T?;
        return ApiResponse<T>(
          success: true,
          data: data,
          statusCode: statusCode,
        );
      } else {
        // Error
        return ApiResponse<T>(
          success: false,
          error: body?['message'] ?? body?['error'] ?? 'Request failed',
          statusCode: statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        error: 'Failed to parse response: $e',
        statusCode: response.statusCode,
      );
    }
  }

  /// Handle Dio error and convert to ApiResponse
  ApiResponse<T> _handleError<T>(DioException error) {
    String errorMessage = 'An error occurred';
    
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      errorMessage = 'Request timeout. Please check your connection.';
    } else if (error.type == DioExceptionType.connectionError) {
      errorMessage = 'No internet connection. Please check your network.';
    } else if (error.response != null) {
      // Server responded with error
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;
      errorMessage = data?['message'] ?? 
                     data?['error'] ?? 
                     'Server error (${statusCode})';
      
      return ApiResponse<T>(
        success: false,
        error: errorMessage,
        statusCode: statusCode,
      );
    } else {
      errorMessage = error.message ?? 'Unknown error occurred';
    }

    return ApiResponse<T>(
      success: false,
      error: errorMessage,
    );
  }

  /// GET request
  /// 
  /// Example:
  /// ```dart
  /// final response = await apiClient.get('/users/123');
  /// if (response.success) {
  ///   print(response.data);
  /// }
  /// ```
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParams,
        options: Options(headers: headers),
        cancelToken: cancelToken,
      );

      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// POST request
  /// 
  /// Example:
  /// ```dart
  /// final response = await apiClient.post(
  ///   '/users',
  ///   body: {'name': 'John', 'email': 'john@example.com'},
  /// );
  /// ```
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: body,
        options: Options(headers: headers),
        cancelToken: cancelToken,
      );

      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// PUT request
  /// 
  /// Example:
  /// ```dart
  /// final response = await apiClient.put(
  ///   '/users/123',
  ///   body: {'name': 'John Updated'},
  /// );
  /// ```
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: body,
        options: Options(headers: headers),
        cancelToken: cancelToken,
      );

      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// DELETE request
  /// 
  /// Example:
  /// ```dart
  /// final response = await apiClient.delete('/users/123');
  /// ```
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        data: body,
        options: Options(headers: headers),
        cancelToken: cancelToken,
      );

      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Upload file(s) using multipart/form-data
  /// 
  /// Example:
  /// ```dart
  /// final response = await apiClient.uploadFile(
  ///   '/complaints/upload',
  ///   file: File('/path/to/image.jpg'),
  ///   fieldName: 'image',
  ///   additionalData: {'complaintId': '123'},
  /// );
  /// ```
  Future<ApiResponse<T>> uploadFile<T>(
    String endpoint, {
    required File file,
    String fieldName = 'file',
    Map<String, dynamic>? additionalData,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        if (additionalData != null) ...additionalData,
      });

      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(headers: headers),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );

      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Upload multiple files
  /// 
  /// Example:
  /// ```dart
  /// final response = await apiClient.uploadFiles(
  ///   '/complaints/upload-multiple',
  ///   files: [file1, file2],
  ///   fieldName: 'images',
  /// );
  /// ```
  Future<ApiResponse<T>> uploadFiles<T>(
    String endpoint, {
    required List<File> files,
    String fieldName = 'files',
    Map<String, dynamic>? additionalData,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      // Create multipart files
      final multipartFiles = await Future.wait(
        files.map((file) async {
          final fileName = file.path.split('/').last;
          return await MultipartFile.fromFile(
            file.path,
            filename: fileName,
          );
        }),
      );

      final formData = FormData.fromMap({
        fieldName: multipartFiles,
        if (additionalData != null) ...additionalData,
      });

      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(headers: headers),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );

      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Set authentication token (saves to SharedPreferences)
  Future<void> setAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  /// Clear authentication token
  Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  /// Save user data to SharedPreferences
  /// Stores user data as JSON string with key "user"
  Future<void> saveUser(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    // Convert to JSON string and save
    final userJson = jsonEncode(userData);
    await prefs.setString('user', userJson);
  }

  /// Get user data from SharedPreferences
  /// Returns null if user data doesn't exist
  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson == null) return null;
    
    try {
      return jsonDecode(userJson) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Clear user data from SharedPreferences
  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
  }
}

