/// User Model
/// Represents the logged-in user data from the API
class UserModel {
  final String id;
  final String name;
  final String userType; // CUSTOMER, ADMIN, AGENT
  final String? email; // Present in signup response
  final String? message;
  final bool success;

  UserModel({
    required this.id,
    required this.name,
    required this.userType,
    this.email,
    this.message,
    required this.success,
  });

  /// Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      userType: json['userType'] as String? ?? 'CUSTOMER', // Default to CUSTOMER if not present
      email: json['email'] as String?,
      message: json['message'] as String?,
      success: json['success'] as bool? ?? true,
    );
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'userType': userType,
      if (email != null) 'email': email,
      if (message != null) 'message': message,
      'success': success,
    };
  }

  /// Check if user is Customer
  bool get isCustomer => userType.toUpperCase() == 'CUSTOMER';

  /// Check if user is Admin
  bool get isAdmin => userType.toUpperCase() == 'ADMIN';

  /// Check if user is Agent
  bool get isAgent => userType.toUpperCase() == 'AGENT';

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, userType: $userType)';
  }
}

