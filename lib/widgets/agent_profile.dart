import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../services/agent_service.dart';
import '../services/complaint_service.dart';
import '../models/user_model.dart';
import '../api/api_config.dart';
import 'complaint_detail.dart';

// Import File only for non-web platforms
import 'dart:io' if (dart.library.html) '../io_stub.dart' show File;

class AgentProfilePage extends StatefulWidget {
  const AgentProfilePage({super.key});

  @override
  State<AgentProfilePage> createState() => _AgentProfilePageState();
}

class _AgentProfilePageState extends State<AgentProfilePage> {
  UserModel? _user;
  bool _isLoading = true;
  String? _error;
  final _authService = AuthService();
  final _agentService = AgentService();
  final _complaintService = ComplaintService();
  final _imagePicker = ImagePicker();

  Map<String, dynamic>? _profileData;
  List<dynamic> _activeComplaints = [];
  List<dynamic> _closedComplaints = [];
  String _selectedTab = 'active'; // 'active' or 'closed'

  // Update form controllers
  final _passwordController = TextEditingController();
  bool _isUpdating = false;

  // Image picker state
  dynamic _selectedImage; // dart:io.File on non-web, null on web
  Uint8List? _selectedImageBytes; // For web compatibility
  Uint8List? _selectedImageBytesForPreview; // For preview on non-web
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get user from local storage
      final user = await _authService.getStoredUser();
      if (user == null) {
        setState(() {
          _error = 'No user data found';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _user = user;
      });

      // Fetch profile data from API
      final response = await _agentService.getAgentProfile(user.id);

      if (response.success && response.data != null) {
        setState(() {
          _profileData = response.data;
          _activeComplaints = response.data!['activeComplaints'] as List<dynamic>? ?? [];
          _closedComplaints = response.data!['closedComplaints'] as List<dynamic>? ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.error ?? 'Failed to load profile';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading profile: $e';
        _isLoading = false;
      });
    }
  }

  /// Pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          setState(() {
            _selectedImageBytes = null; // Will be loaded asynchronously
            _selectedImage = null;
          });
          _loadImageBytes(pickedFile);
        } else {
          // Load bytes for preview
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _selectedImage = File(pickedFile.path);
            _selectedImageBytes = null;
            _selectedImageBytesForPreview = bytes;
          });
        }
        // Automatically upload after picking
        await _uploadAndUpdateProfilePhoto();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Load image bytes for web
  Future<void> _loadImageBytes(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
      });
      // Automatically upload after loading bytes
      await _uploadAndUpdateProfilePhoto();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Show image source selection dialog
  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Upload image and update profile photo
  Future<void> _uploadAndUpdateProfilePhoto() async {
    if (_user == null) return;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      String? imageUrl;

      // Upload image first if one is selected
      if (_selectedImage != null || _selectedImageBytes != null) {
        final uploadResponse = kIsWeb
            ? await _complaintService.uploadImage(
                imageFile: null,
                imageBytes: _selectedImageBytes,
                fileName: _selectedImageBytes != null ? 'profile.jpg' : null,
              )
            : await _complaintService.uploadImage(
                imageFile: _selectedImage as dynamic,
                imageBytes: null,
                fileName: null,
              );

        if (!uploadResponse.success) {
          setState(() {
            _isUploadingImage = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(uploadResponse.error ?? 'Failed to upload image. Please try again.'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
          return;
        }

        // Extract URL from response
        if (uploadResponse.data != null) {
          imageUrl = uploadResponse.data!['url'] as String?;
        }
      }

      if (imageUrl == null || imageUrl.isEmpty) {
        setState(() {
          _isUploadingImage = false;
        });
        return;
      }

      // Update profile with image URL
      final response = await _agentService.updateAgentProfile(
        agentId: _user!.id,
        password: null,
        profilePhotoUrl: imageUrl,
      );

      if (response.success && response.data != null) {
        // Update local profile data
        setState(() {
          if (_profileData?['agent'] != null) {
            _profileData!['agent'] = response.data;
          }
          _selectedImage = null;
          _selectedImageBytes = null;
          _selectedImageBytesForPreview = null;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile photo updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          // Reload profile data
          _loadProfileData();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.error ?? 'Failed to update profile photo'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_user == null) return;

    final password = _passwordController.text.trim();

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a password to update'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      final response = await _agentService.updateAgentProfile(
        agentId: _user!.id,
        password: password,
        profilePhotoUrl: null,
      );

      if (response.success && response.data != null) {
        // Update local profile data
        setState(() {
          if (_profileData?['agent'] != null) {
            _profileData!['agent'] = response.data;
          }
          _passwordController.clear();
        });

        if (mounted) {
          Navigator.of(context).pop(); // Close dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          // Reload profile data
          _loadProfileData();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.error ?? 'Failed to update password'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating password: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  void _showUpdateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Update Password',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    hintText: 'Enter new password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isUpdating
                  ? null
                  : () {
                      _passwordController.clear();
                      Navigator.of(context).pop();
                    },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _isUpdating ? null : _updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF136AF6),
                foregroundColor: Colors.white,
              ),
              child: _isUpdating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Map<String, dynamic>? get _agentData {
    return _profileData?['agent'] as Map<String, dynamic>?;
  }

  String _getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) return imagePath;
    final baseUrl = ApiConfig.baseUrl;
    if (imagePath.startsWith('/')) {
      return '$baseUrl$imagePath';
    }
    return '$baseUrl/$imagePath';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7F8),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF136AF6),
          ),
        ),
      );
    }

    if (_error != null || _user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7F8),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  _error ?? 'No user data found',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111318),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final agentData = _agentData;
    final profilePhotoUrl = _getImageUrl(agentData?['profilePhotoUrl']);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF136AF6),
                    const Color(0xFF136AF6).withOpacity(0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Profile',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: _showUpdateDialog,
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Profile Section
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Profile Photo (clickable)
                  GestureDetector(
                    onTap: _isUploadingImage ? null : _showImageSourceDialog,
                    child: Stack(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF136AF6).withOpacity(0.15),
                                const Color(0xFF136AF6).withOpacity(0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(45),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(45),
                            child: _selectedImageBytesForPreview != null
                                ? Image.memory(
                                    _selectedImageBytesForPreview!,
                                    fit: BoxFit.cover,
                                  )
                                : _selectedImageBytes != null && kIsWeb
                                    ? Image.memory(
                                        _selectedImageBytes!,
                                        fit: BoxFit.cover,
                                      )
                                    : profilePhotoUrl.isNotEmpty
                                        ? Image.network(
                                            profilePhotoUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.person,
                                                size: 45,
                                                color: Color(0xFF136AF6),
                                              );
                                            },
                                          )
                                        : const Icon(
                                            Icons.person,
                                            size: 45,
                                            color: Color(0xFF136AF6),
                                          ),
                          ),
                        ),
                        if (_isUploadingImage)
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(45),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          )
                        else
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: const Color(0xFF136AF6),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 20),
                  
                  // Name, Phone, Department Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Name
                        Text(
                          agentData?['name'] ?? _user?.name ?? 'Agent',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111318),
                            letterSpacing: -0.5,
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Contact Information
                        if (agentData?['phone'] != null)
                          Row(
                            children: [
                              const Icon(
                                Icons.phone_rounded,
                                size: 16,
                                color: Color(0xFF5F708C),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  agentData!['phone'].toString(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF5F708C),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        if (agentData?['department'] != null) ...[
                          if (agentData?['phone'] != null) const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.work,
                                size: 16,
                                color: Color(0xFF5F708C),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  agentData!['department'].toString(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF5F708C),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Stats Section
            if (agentData != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Assigned',
                        agentData['assignedComplaint']?.toString() ?? '0',
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'In Progress',
                        agentData['complaintsInProgress']?.toString() ?? '0',
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Closed',
                        agentData['closedComplaints']?.toString() ?? '0',
                        Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Complaints Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text(
                    'Complaints',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111318),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF136AF6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_activeComplaints.length + _closedComplaints.length} Total',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF136AF6),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tab Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabButton(
                      label: 'Active',
                      count: _activeComplaints.length,
                      isSelected: _selectedTab == 'active',
                      onTap: () => setState(() => _selectedTab = 'active'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTabButton(
                      label: 'Closed',
                      count: _closedComplaints.length,
                      isSelected: _selectedTab == 'closed',
                      onTap: () => setState(() => _selectedTab = 'closed'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Complaints List
            Expanded(
              child: _buildComplaintsList(),
            ),

            // Logout Button
            Container(
              margin: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              height: 56,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: const Text(
                          'Logout',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await _authService.logout();
                              if (mounted) {
                                Navigator.of(context).pushReplacementNamed('/login');
                              }
                            },
                            child: const Text(
                              'Logout',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF5F708C),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF136AF6) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF136AF6) : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF136AF6).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF1E293B),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.25)
                      : const Color(0xFF136AF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF136AF6),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComplaintsList() {
    final complaints = _selectedTab == 'active' ? _activeComplaints : _closedComplaints;

    if (complaints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                _selectedTab == 'active' ? Icons.inbox_outlined : Icons.check_circle_outline,
                size: 56,
                color: const Color(0xFF5F708C).withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _selectedTab == 'active'
                  ? 'No active complaints'
                  : 'No closed complaints',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5F708C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedTab == 'active'
                  ? 'All your complaints are resolved!'
                  : 'You haven\'t closed any complaints yet',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF5F708C),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: complaints.length,
      itemBuilder: (context, index) {
        final complaint = complaints[index] as Map<String, dynamic>;
        return _buildComplaintCard(complaint);
      },
    );
  }

  Widget _buildComplaintCard(Map<String, dynamic> complaint) {
    final title = complaint['title']?.toString() ?? 'Untitled';
    final description = complaint['description']?.toString() ?? '';
    final status = complaint['status']?.toString() ?? '';
    final severity = complaint['severity']?.toString() ?? '';
    final department = complaint['department']?.toString() ?? '';
    final location = complaint['location']?.toString() ?? '';
    final complaintId = complaint['id']?.toString() ?? '';

    Color statusColor = const Color(0xFF5F708C);
    if (status == 'RAISED') {
      statusColor = Colors.orange;
    } else if (status == 'IN_PROGRESS' || status == 'ASSIGNED' || status == 'AGENT_ASSIGNED') {
      statusColor = Colors.blue;
    } else if (status == 'COMPLETED' || status == 'RESOLVED' || status == 'FIXED') {
      statusColor = Colors.green;
    }

    Color severityColor = const Color(0xFF5F708C);
    if (severity == 'HIGH') {
      severityColor = Colors.red;
    } else if (severity == 'MEDIUM') {
      severityColor = Colors.orange;
    } else if (severity == 'LOW') {
      severityColor = Colors.green;
    }

    final bool isAgentAssigned = status == 'AGENT_ASSIGNED';
    final bool isInProgress = status == 'IN_PROGRESS';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card content (clickable to open details)
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ComplaintDetailPage(
                    complaintId: complaintId,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111318),
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: statusColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF5F708C),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  
                  const SizedBox(height: 14),
                  
                  // Details Row
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (department.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF136AF6).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.category,
                                size: 14,
                                color: Color(0xFF136AF6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                department,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF136AF6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (severity.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: severityColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.flag,
                                size: 14,
                                color: severityColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                severity,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: severityColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (location.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF5F708C).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 14,
                                color: Color(0xFF5F708C),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  location,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF5F708C),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Action buttons based on status
          if (isAgentAssigned || isInProgress)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                border: const Border(
                  top: BorderSide(
                    color: Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: isAgentAssigned
                    ? SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _handleStartProgress(complaintId),
                          icon: const Icon(Icons.play_arrow, size: 20),
                          label: const Text('Start Progress'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF136AF6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showCloseComplaintDialog(complaintId),
                          icon: const Icon(Icons.check_circle, size: 20),
                          label: const Text('Close Complaint'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleStartProgress(String complaintId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Start Progress'),
        content: const Text('Are you sure you want to start working on this complaint?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF136AF6),
              foregroundColor: Colors.white,
            ),
            child: const Text('Start'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Show loading
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 16),
              Text('Starting progress...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }

    try {
      final response = await _complaintService.startProgress(complaintId);

      if (response.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Complaint status updated to IN_PROGRESS'),
              backgroundColor: Colors.green,
            ),
          );
          // Reload profile data
          _loadProfileData();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.error ?? 'Failed to start progress'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCloseComplaintDialog(String complaintId) {
    dynamic closeImage;
    Uint8List? closeImageBytes;
    bool isUploadingCloseImage = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Close Complaint'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Please upload an "after" photo to close this complaint.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    if (closeImageBytes != null)
                      Stack(
                        children: [
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                closeImageBytes!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black54,
                              ),
                              onPressed: () {
                                setDialogState(() {
                                  closeImage = null;
                                  closeImageBytes = null;
                                });
                              },
                            ),
                          ),
                        ],
                      )
                    else
                      GestureDetector(
                        onTap: () async {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext bottomSheetContext) {
                              return SafeArea(
                                child: Wrap(
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.photo_library),
                                      title: const Text('Choose from Gallery'),
                                      onTap: () {
                                        Navigator.pop(bottomSheetContext);
                                        _pickCloseImage(ImageSource.gallery, setDialogState, (img, bytes) {
                                          closeImage = img;
                                          closeImageBytes = bytes;
                                        });
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.camera_alt),
                                      title: const Text('Take a Photo'),
                                      onTap: () {
                                        Navigator.pop(bottomSheetContext);
                                        _pickCloseImage(ImageSource.camera, setDialogState, (img, bytes) {
                                          closeImage = img;
                                          closeImageBytes = bytes;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Tap to add photo'),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isUploadingCloseImage
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isUploadingCloseImage || closeImageBytes == null
                      ? null
                      : () async {
                          setDialogState(() {
                            isUploadingCloseImage = true;
                          });

                          try {
                            // Upload image first
                            String? imageUrl;
                            final uploadResponse = kIsWeb
                                ? await _complaintService.uploadImage(
                                    imageFile: null,
                                    imageBytes: closeImageBytes,
                                    fileName: 'close_photo.jpg',
                                  )
                                : await _complaintService.uploadImage(
                                    imageFile: closeImage as dynamic,
                                    imageBytes: null,
                                    fileName: null,
                                  );

                            if (!uploadResponse.success) {
                              setDialogState(() {
                                isUploadingCloseImage = false;
                              });
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(uploadResponse.error ?? 'Failed to upload image'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                              return;
                            }

                            if (uploadResponse.data != null) {
                              imageUrl = uploadResponse.data!['url'] as String?;
                            }

                            if (imageUrl == null || imageUrl.isEmpty) {
                              setDialogState(() {
                                isUploadingCloseImage = false;
                              });
                              return;
                            }

                            // Close complaint with image URL
                            final response = await _complaintService.closeComplaint(
                              complaintId: complaintId,
                              afterPhotoUrl: imageUrl,
                            );

                            if (response.success) {
                              if (mounted) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Complaint closed successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                // Reload profile data
                                _loadProfileData();
                              }
                            } else {
                              setDialogState(() {
                                isUploadingCloseImage = false;
                              });
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(response.error ?? 'Failed to close complaint'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            setDialogState(() {
                              isUploadingCloseImage = false;
                            });
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: isUploadingCloseImage
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Close Complaint'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _pickCloseImage(
    ImageSource source,
    StateSetter setDialogState,
    Function(dynamic, Uint8List?) callback,
  ) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Always read bytes for preview
        final bytes = await pickedFile.readAsBytes();
        if (kIsWeb) {
          setDialogState(() {
            callback(null, bytes);
          });
        } else {
          setDialogState(() {
            callback(File(pickedFile.path), bytes);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

