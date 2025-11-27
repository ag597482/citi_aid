import '../api/api_client.dart';
import '../api/api_response.dart';
import '../api/api_endpoints.dart';

/// Agent Service
/// Handles all agent-related API calls
class AgentService {
  final _api = ApiClient();

  /// Get all agents
  Future<ApiResponse<List<dynamic>>> getAllAgents() async {
    return await _api.get<List<dynamic>>(
      ApiEndpoints.agents,
      fromJson: (json) => json is List ? json : [],
    );
  }

  /// Get all agents (user endpoint)
  Future<ApiResponse<List<dynamic>>> getAllUserAgents() async {
    return await _api.get<List<dynamic>>(
      ApiEndpoints.userAgents,
      fromJson: (json) => json is List ? json : [],
    );
  }

  /// Get agents by department
  /// 
  /// Example:
  /// ```dart
  /// final response = await agentService.getAgentsByDepartment('POTHOLES');
  /// ```
  Future<ApiResponse<List<dynamic>>> getAgentsByDepartment(String department) async {
    return await _api.get<List<dynamic>>(
      ApiEndpoints.userAgentsByDepartment(department),
      fromJson: (json) => json is List ? json : [],
    );
  }

  /// Get agent by ID
  Future<ApiResponse<Map<String, dynamic>>> getAgentById(String id) async {
    return await _api.get<Map<String, dynamic>>(ApiEndpoints.agentById(id));
  }

  /// Create new agent
  /// 
  /// Example:
  /// ```dart
  /// final response = await agentService.createAgent(
  ///   name: 'John Doe',
  ///   phone: '1234567890',
  ///   password: 'password123',
  ///   document: 'document/path',
  ///   department: 'ELECTRICITY',
  /// );
  /// ```
  Future<ApiResponse<Map<String, dynamic>>> createAgent({
    required String name,
    required String phone,
    required String password,
    required String document,
    required String department,
  }) async {
    return await _api.post<Map<String, dynamic>>(
      ApiEndpoints.createAgent,
      body: {
        'name': name,
        'phone': phone,
        'password': password,
        'document': document,
        'department': department,
      },
    );
  }

  /// Update agent
  Future<ApiResponse<Map<String, dynamic>>> updateAgent({
    required String id,
    String? name,
    String? phone,
    String? department,
    bool? isActive,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (phone != null) body['phone'] = phone;
    if (department != null) body['department'] = department;
    if (isActive != null) body['isActive'] = isActive;

    return await _api.put<Map<String, dynamic>>(
      ApiEndpoints.agentById(id),
      body: body,
    );
  }

  /// Delete agent
  Future<ApiResponse<Map<String, dynamic>>> deleteAgent(String id) async {
    return await _api.delete<Map<String, dynamic>>(ApiEndpoints.agentById(id));
  }

  /// Assign agent to complaint
  Future<ApiResponse<Map<String, dynamic>>> assignToComplaint({
    required String agentId,
    required String complaintId,
  }) async {
    return await _api.post<Map<String, dynamic>>(
      ApiEndpoints.agentAssign(agentId),
      body: {'complaintId': complaintId},
    );
  }

  /// Get agent's assigned complaints
  Future<ApiResponse<List<dynamic>>> getAssignedComplaints(String agentId) async {
    return await _api.get<List<dynamic>>(
      ApiEndpoints.agentComplaints(agentId),
      fromJson: (json) => json is List ? json : [],
    );
  }
}

