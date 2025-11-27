/// API Endpoints
/// Centralized collection of all API endpoint paths
/// This makes it easy to update endpoints in one place
class ApiEndpoints {
  // ==================== Authentication Endpoints ====================
  static const String customerLogin = '/auth/customer/login';
  static const String agentLogin = '/auth/agent/login';
  static const String adminLogin = '/auth/admin/login';
  static const String customerSignup = '/auth/customer/signup';
  static const String customerRegister = '/auth/customer/register'; // Deprecated, use customerSignup
  static const String agentRegister = '/auth/agent/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String getCurrentUser = '/auth/me';
  static const String logout = '/auth/logout';
  
  // ==================== Complaint Endpoints ====================
  static const String complaints = '/complaints';
  static String complaintById(String id) => '/complaints/$id';
  static String complaintImage(String id) => '/complaints/$id/image';
  static String complaintLike(String id) => '/complaints/$id/like';
  static String complaintFixed(String id) => '/complaints/$id/fixed';
  static String complaintAssign(String complaintId, String agentId) => '/complaints/$complaintId/assign/$agentId';
  static String complaintDiscard(String id) => '/complaints/$id/discard';
  static String complaintsByStatus(String status) => '/complaints/status/$status';
  static const String myComplaints = '/complaints/my';
  static const String complaintsSummary = '/complaints/summary';
  
  // ==================== Agent Endpoints ====================
  static const String agents = '/agents';
  static const String userAgents = '/user/agents';
  static String userAgentsByDepartment(String department) => '/user/agents/department/$department';
  static const String createAgent = '/user/agent/create';
  static String agentById(String id) => '/agents/$id';
  static String agentAssign(String id) => '/agents/$id/assign';
  static String agentComplaints(String id) => '/agents/$id/complaints';
  
  // ==================== Customer Endpoints ====================
  static const String customerProfile = '/customers/profile';
  static const String customerComplaints = '/customers/complaints';
  static String customerProfileById(String customerId) => '/user/customer/profile/$customerId';
  
  // ==================== Admin Endpoints ====================
  static const String adminStats = '/admin/stats';
  static const String adminUsers = '/admin/users';
  
  // ==================== Image Upload Endpoints ====================
  static const String imageUpload = '/api/images/upload';
}

