import 'dart:io';
import '../api/api_client.dart';
import '../api/api_response.dart';
import '../api/api_endpoints.dart';

/// Complaint Service
/// Handles all complaint-related API calls
class ComplaintService {
  final _api = ApiClient();

  /// Get all complaints (feed)
  /// 
  /// Example:
  /// ```dart
  /// final complaintService = ComplaintService();
  /// final response = await complaintService.getAllComplaints();
  /// 
  /// if (response.success) {
  ///   final complaints = response.data as List;
  ///   // Use complaints
  /// }
  /// ```
  Future<ApiResponse<List<dynamic>>> getAllComplaints({
    Map<String, dynamic>? filters,
  }) async {
    return await _api.get<List<dynamic>>(
      ApiEndpoints.complaints,
      queryParams: filters,
      fromJson: (json) => json is List ? json : [],
    );
  }

  /// Get complaint by ID
  Future<ApiResponse<Map<String, dynamic>>> getComplaintById(String id) async {
    return await _api.get<Map<String, dynamic>>(ApiEndpoints.complaintById(id));
  }

  /// Create new complaint
  /// 
  /// Example:
  /// ```dart
  /// final response = await complaintService.createComplaint(
  ///   title: 'Power outage',
  ///   description: 'No electricity for 2 days',
  ///   category: 'Electricity',
  ///   priority: 'High',
  ///   latitude: 28.6139,
  ///   longitude: 77.2090,
  /// );
  /// ```
  Future<ApiResponse<Map<String, dynamic>>> createComplaint({
    required String title,
    required String description,
    required String category,
    required String priority,
    double? latitude,
    double? longitude,
    String? imageUrl,
  }) async {
    return await _api.post<Map<String, dynamic>>(
      ApiEndpoints.complaints,
      body: {
        'title': title,
        'description': description,
        'category': category,
        'priority': priority,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (imageUrl != null) 'imageUrl': imageUrl,
      },
    );
  }

  /// Update complaint
  Future<ApiResponse<Map<String, dynamic>>> updateComplaint({
    required String id,
    String? title,
    String? description,
    String? status,
    String? priority,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (status != null) body['status'] = status;
    if (priority != null) body['priority'] = priority;

    return await _api.put<Map<String, dynamic>>(
      ApiEndpoints.complaintById(id),
      body: body,
    );
  }

  /// Delete complaint
  Future<ApiResponse<Map<String, dynamic>>> deleteComplaint(String id) async {
    return await _api.delete<Map<String, dynamic>>(ApiEndpoints.complaintById(id));
  }

  /// Get user's complaints
  Future<ApiResponse<List<dynamic>>> getMyComplaints() async {
    return await _api.get<List<dynamic>>(
      ApiEndpoints.myComplaints,
      fromJson: (json) => json is List ? json : [],
    );
  }

  /// Like/Unlike complaint
  Future<ApiResponse<Map<String, dynamic>>> toggleLike(String complaintId) async {
    return await _api.post<Map<String, dynamic>>(
      ApiEndpoints.complaintLike(complaintId),
    );
  }

  /// Mark complaint as fixed
  Future<ApiResponse<Map<String, dynamic>>> markAsFixed(String complaintId) async {
    return await _api.put<Map<String, dynamic>>(
      ApiEndpoints.complaintFixed(complaintId),
    );
  }

  /// Upload complaint image
  /// 
  /// Example:
  /// ```dart
  /// final response = await complaintService.uploadComplaintImage(
  ///   complaintId: '123',
  ///   imageFile: File('/path/to/image.jpg'),
  ///   onProgress: (sent, total) {
  ///     print('Upload progress: ${(sent / total * 100).toStringAsFixed(0)}%');
  ///   },
  /// );
  /// ```
  Future<ApiResponse<Map<String, dynamic>>> uploadComplaintImage({
    required String complaintId,
    required File imageFile,
    void Function(int, int)? onProgress,
  }) async {
    return await _api.uploadFile<Map<String, dynamic>>(
      ApiEndpoints.complaintImage(complaintId),
      file: imageFile,
      fieldName: 'image',
      additionalData: {'complaintId': complaintId},
      onSendProgress: onProgress,
    );
  }
}

