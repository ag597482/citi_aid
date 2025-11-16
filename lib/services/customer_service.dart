import '../api/api_client.dart';
import '../api/api_response.dart';
import '../api/api_endpoints.dart';

/// Customer Service
/// Handles all customer-related API calls
class CustomerService {
  final _api = ApiClient();

  /// Get customer profile
  Future<ApiResponse<Map<String, dynamic>>> getProfile() async {
    return await _api.get<Map<String, dynamic>>(ApiEndpoints.customerProfile);
  }

  /// Update customer profile
  Future<ApiResponse<Map<String, dynamic>>> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (phone != null) body['phone'] = phone;
    if (address != null) body['address'] = address;

    return await _api.put<Map<String, dynamic>>(
      ApiEndpoints.customerProfile,
      body: body,
    );
  }

  /// Get customer's complaint history
  Future<ApiResponse<List<dynamic>>> getComplaintHistory() async {
    return await _api.get<List<dynamic>>(
      ApiEndpoints.customerComplaints,
      fromJson: (json) => json is List ? json : [],
    );
  }

  /// Get customer profile by ID (includes active and closed complaints)
  Future<ApiResponse<Map<String, dynamic>>> getProfileById(String customerId) async {
    return await _api.get<Map<String, dynamic>>(
      ApiEndpoints.customerProfileById(customerId),
    );
  }
}

