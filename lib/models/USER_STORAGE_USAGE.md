# User Storage Usage Guide

## Overview

After successful login, the user data is automatically saved to SharedPreferences with the key `"user"`.

The stored data structure matches your API response:
```json
{
  "id": "69178ff452bebd3ab9f72c96",
  "name": "test",
  "userType": "CUSTOMER",
  "message": "Login successful",
  "success": true
}
```

---

## How It Works

### 1. **Automatic Storage on Login**

When login is successful, the user data is automatically saved:

```dart
final response = await authService.login(
  identifier: 'test@gmail.com',
  password: 'password',
  role: 'Customer',
);

// User data is automatically saved to SharedPreferences
// Key: "user"
// Value: JSON string of the response data
```

### 2. **Retrieve Stored User**

```dart
import '../services/auth_service.dart';
import '../models/user_model.dart';

final authService = AuthService();

// Get stored user
final user = await authService.getStoredUser();

if (user != null) {
  print('User ID: ${user.id}');
  print('User Name: ${user.name}');
  print('User Type: ${user.userType}'); // CUSTOMER, ADMIN, AGENT
  
  // Check user type
  if (user.isCustomer) {
    // Customer-specific logic
  } else if (user.isAdmin) {
    // Admin-specific logic
  } else if (user.isAgent) {
    // Agent-specific logic
  }
}
```

### 3. **Check Login Status**

```dart
final isLoggedIn = await authService.isLoggedIn();
if (isLoggedIn) {
  // User is logged in
} else {
  // User is not logged in, redirect to login
}
```

### 4. **Clear User Data on Logout**

```dart
await authService.logout();
// This clears both:
// - auth_token
// - user data
```

---

## Usage Examples

### Example 1: Check User on App Start

```dart
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _authService = AuthService();
  bool _isLoading = true;
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final user = await _authService.getStoredUser();
    setState(() {
      _user = user;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return CircularProgressIndicator();
    }

    return MaterialApp(
      home: _user != null ? HomePage() : LoginPage(),
    );
  }
}
```

### Example 2: Display User Info in Profile

```dart
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _authService = AuthService();
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _authService.getStoredUser();
    setState(() {
      _user = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Center(child: Text('No user data'));
    }

    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Column(
        children: [
          Text('Name: ${_user!.name}'),
          Text('User Type: ${_user!.userType}'),
          Text('ID: ${_user!.id}'),
        ],
      ),
    );
  }
}
```

### Example 3: Role-Based Navigation

```dart
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: AuthService().getStoredUser(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LoginPage();
        }

        final user = snapshot.data!;

        // Navigate based on user type
        if (user.isAdmin) {
          return AdminHomePage();
        } else if (user.isAgent) {
          return AgentHomePage();
        } else {
          return CustomerFeedPage();
        }
      },
    );
  }
}
```

### Example 4: Conditional UI Based on User Type

```dart
Widget buildUserSpecificWidget() {
  return FutureBuilder<UserModel?>(
    future: AuthService().getStoredUser(),
    builder: (context, snapshot) {
      final user = snapshot.data;
      
      if (user == null) {
        return Text('Not logged in');
      }

      if (user.isAdmin) {
        return AdminDashboard();
      } else if (user.isAgent) {
        return AgentDashboard();
      } else {
        return CustomerDashboard();
      }
    },
  );
}
```

---

## Direct Access (Advanced)

If you need direct access to the raw user data:

```dart
import '../api/api_client.dart';

final api = ApiClient();

// Get raw user data as Map
final userData = await api.getUser();
if (userData != null) {
  print(userData['id']);
  print(userData['name']);
  print(userData['userType']);
}

// Save user data manually (usually not needed)
await api.saveUser({
  'id': '123',
  'name': 'John',
  'userType': 'CUSTOMER',
  'success': true,
});

// Clear user data manually
await api.clearUser();
```

---

## Storage Details

- **Storage Key**: `"user"`
- **Storage Type**: SharedPreferences (String)
- **Format**: JSON string
- **Location**: Device local storage (persists across app restarts)

---

## UserModel Properties

```dart
class UserModel {
  final String id;           // User ID
  final String name;         // User name
  final String userType;     // CUSTOMER, ADMIN, or AGENT
  final String? message;     // Optional message
  final bool success;         // Success flag

  // Helper methods
  bool get isCustomer;       // true if userType == 'CUSTOMER'
  bool get isAdmin;          // true if userType == 'ADMIN'
  bool get isAgent;           // true if userType == 'AGENT'
}
```

---

## Summary

✅ **Automatic**: User data is saved automatically on successful login  
✅ **Persistent**: Data persists across app restarts  
✅ **Type-Safe**: Use `UserModel` for type-safe access  
✅ **Easy Access**: Simple methods to get/check user data  
✅ **Auto-Cleanup**: User data cleared on logout

