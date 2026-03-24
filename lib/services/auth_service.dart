import '../api/api_client.dart';
import '../api/api_response.dart';
import '../api/api_endpoints.dart';
import '../models/user_model.dart';

/// Authentication Service
/// Handles all authentication-related API calls
class AuthService {
  final _api = ApiClient();

  /// Login user based on role
  /// 
  /// Example:
  /// ```dart
  /// final authService = AuthService();
  /// final response = await authService.login(
  ///   identifier: 'test@gmail.com',
  ///   password: 'password123',
  ///   role: 'Customer', // or 'Agent' or 'Admin'
  /// );
  /// 
  /// if (response.success) {
  ///   // Token is automatically saved
  ///   // Navigate to home
  /// } else {
  ///   // Show error: response.error
  /// }
  /// ```
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String identifier, // Can be email or phone
    required String password,
    required String role, // 'Customer', 'Agent', or 'Admin'
  }) async {
    String endpoint;
    
    // Select endpoint based on role
    switch (role.toLowerCase()) {
      case 'customer':
        endpoint = ApiEndpoints.customerLogin;
        break;
      case 'agent':
        endpoint = ApiEndpoints.agentLogin;
        break;
      case 'admin':
        endpoint = ApiEndpoints.adminLogin;
        break;
      default:
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          error: 'Invalid role: $role',
        );
    }

    final response = await _api.post<Map<String, dynamic>>(
      endpoint,
      body: {
        'identifier': identifier,
        'password': password,
      },
    );

    // Auto-save token and user data if login successful
    if (response.success && response.data != null) {
      final data = response.data!;
      
      // Try different possible token field names
      final token = data['token'] as String? ?? 
                   data['accessToken'] as String? ??
                   data['access_token'] as String?;
      if (token != null) {
        await _api.setAuthToken(token);
      }

      // Preserve existing email and phone from local storage if they exist
      final existingUserData = await _api.getUser();
      if (existingUserData != null) {
        // Merge existing email and phone into new data if not present in response
        if (existingUserData['email'] != null && data['email'] == null) {
          data['email'] = existingUserData['email'];
        }
        if (existingUserData['phone'] != null && data['phone'] == null) {
          data['phone'] = existingUserData['phone'];
        }
      }

      // Save user data to SharedPreferences with key "user"
      // The response data contains: id, name, userType, message, success
      // Now also includes preserved email and phone if they existed
      await _api.saveUser(data);
    }

    return response;
  }

  /// Register new customer (Signup)
  /// 
  /// Example:
  /// ```dart
  /// final response = await authService.registerCustomer(
  ///   name: 'test',
  ///   email: 'test@gmail.com',
  ///   phone: '12345',
  ///   password: 'password123',
  /// );
  /// 
  /// if (response.success) {
  ///   // User data is automatically saved
  ///   // Navigate to customer home page
  /// }
  /// ```
  Future<ApiResponse<Map<String, dynamic>>> registerCustomer({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.customerSignup,
      body: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      },
    );

    // Auto-save user data if signup successful
    if (response.success && response.data != null) {
      final data = Map<String, dynamic>.from(response.data!);
      
      // Add userType if not present (for customer signup, it's CUSTOMER)
      if (!data.containsKey('userType')) {
        data['userType'] = 'CUSTOMER';
      }
      
      // Ensure email and phone are included in saved data
      // (API response might not include phone, so we add it from the request)
      if (!data.containsKey('email')) {
        data['email'] = email;
      }
      if (!data.containsKey('phone')) {
        data['phone'] = phone;
      }
      
      // Save user data to SharedPreferences with key "user"
      // The response data contains: id, name, email, phone, message, success, userType
      await _api.saveUser(data);
    }

    return response;
  }

  /// Register new agent
  Future<ApiResponse<Map<String, dynamic>>> registerAgent({
    required String identifier,
    required String password,
    required String name,
    String? phone,
  }) async {
    return await _api.post<Map<String, dynamic>>(
      ApiEndpoints.agentRegister,
      body: {
        'identifier': identifier,
        'password': password,
        'name': name,
        if (phone != null) 'phone': phone,
      },
    );
  }

  /// Logout user
  /// Clears all locally persisted session context
  Future<void> logout() async {
    await _api.clearSessionContext();
  }

  /// Get current logged-in user from local storage
  /// Returns null if no user is logged in
  Future<UserModel?> getStoredUser() async {
    final userData = await _api.getUser();
    if (userData == null) return null;
    
    try {
      return UserModel.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  /// Check if user is logged in
  /// Returns true if user data exists in local storage
  Future<bool> isLoggedIn() async {
    final user = await getStoredUser();
    return user != null;
  }

  /// Get current user profile
  Future<ApiResponse<Map<String, dynamic>>> getCurrentUser() async {
    return await _api.get<Map<String, dynamic>>(ApiEndpoints.getCurrentUser);
  }

  /// Forgot password
  Future<ApiResponse<Map<String, dynamic>>> forgotPassword(String identifier) async {
    return await _api.post<Map<String, dynamic>>(
      ApiEndpoints.forgotPassword,
      body: {'identifier': identifier},
    );
  }

  /// Reset password
  Future<ApiResponse<Map<String, dynamic>>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    return await _api.post<Map<String, dynamic>>(
      ApiEndpoints.resetPassword,
      body: {
        'token': token,
        'password': newPassword,
      },
    );
  }
}

