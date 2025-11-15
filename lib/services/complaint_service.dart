import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../api/api_client.dart';
import '../api/api_response.dart';
import '../api/api_endpoints.dart';
import '../services/auth_service.dart';

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
  ///   title: 'pothole in street',
  ///   description: 'big hole in street',
  ///   location: 'new orr in hsr',
  ///   department: 'ELECTRICITY',
  ///   severity: 'LOW',
  ///   beforePhoto: 'base64_encoded_string', // optional
  /// );
  /// ```
  Future<ApiResponse<Map<String, dynamic>>> createComplaint({
    required String title,
    required String description,
    required String location,
    required String department, // ELECTRICITY, POTHOLES, DRAINAGE, GARBAGE, etc.
    required String severity, // LOW, MEDIUM, HIGH
    String? beforePhoto, // Optional base64 encoded image string
  }) async {
    // Get customerId from local storage
    final authService = AuthService();
    final user = await authService.getStoredUser();
    
    if (user == null || !user.isCustomer) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        error: 'User not logged in or not a customer',
      );
    }

    final body = <String, dynamic>{
      'title': title,
      'description': description,
      'location': location,
      'department': department,
      'severity': severity,
      'customerId': user.id,
    };

    // Add beforePhoto if provided
    if (beforePhoto != null && beforePhoto.isNotEmpty) {
      body['beforePhoto'] = beforePhoto;
    }

    return await _api.post<Map<String, dynamic>>(
      ApiEndpoints.complaints,
      body: body,
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

  /// Upload image to get URL for beforePhoto field
  /// 
  /// Example:
  /// ```dart
  /// final response = await complaintService.uploadImage(
  ///   imageFile: File('/path/to/image.jpg'),
  /// );
  /// 
  /// if (response.success) {
  ///   final url = response.data!['url'] as String;
  ///   // Use url in beforePhoto field
  /// }
  /// ```
  Future<ApiResponse<Map<String, dynamic>>> uploadImage({
    dynamic imageFile, // Use dynamic to accept both dart:io.File and stub File
    Uint8List? imageBytes,
    String? fileName,
    void Function(int, int)? onProgress,
  }) async {
    if (kIsWeb && imageBytes != null) {
      // For web, use bytes upload
      return await _api.uploadFileFromBytes<Map<String, dynamic>>(
        ApiEndpoints.imageUpload,
        bytes: imageBytes,
        fileName: fileName ?? 'image.jpg',
        fieldName: 'file',
        onSendProgress: onProgress,
      );
    } else if (imageFile != null && !kIsWeb) {
      // For non-web platforms, use file upload
      // Cast to File for the API call
      return await _api.uploadFile<Map<String, dynamic>>(
        ApiEndpoints.imageUpload,
        file: imageFile as File,
        fieldName: 'file',
        onSendProgress: onProgress,
      );
    } else {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        error: 'Either imageFile or imageBytes must be provided',
      );
    }
  }
}

