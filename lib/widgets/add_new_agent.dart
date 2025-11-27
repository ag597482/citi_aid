import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart' as file_picker;
import '../services/agent_service.dart';
import '../api/api_client.dart';
import '../api/api_response.dart';

// Import File only for non-web platforms
import 'dart:io' if (dart.library.html) '../io_stub.dart' show File;
import 'dart:io' as io;

class AddNewAgentPage extends StatefulWidget {
  const AddNewAgentPage({super.key});

  @override
  State<AddNewAgentPage> createState() => _AddNewAgentPageState();
}

class _AddNewAgentPageState extends State<AddNewAgentPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController(text: 'Ag3ntP@ssw0rd!23');
  
  String? _selectedDepartment; // Stores the enum value (e.g., 'ELECTRICITY')
  bool _isLoading = false;
  
  // Document upload
  dynamic _selectedDocument; // dart:io.File on non-web, null on web
  Uint8List? _selectedDocumentBytes; // For web compatibility
  String? _selectedDocumentName; // Document filename
  final _agentService = AgentService();
  final _imagePicker = ImagePicker();
  final _api = ApiClient();

  // Map department names to backend enum values
  final List<Map<String, String>> _departments = [
    {'name': 'Select Department', 'value': ''},
    {'name': 'Electricity', 'value': 'ELECTRICITY'},
    {'name': 'Potholes', 'value': 'POTHOLES'},
    {'name': 'Drainage', 'value': 'DRAINAGE'},
    {'name': 'Garbage', 'value': 'GARBAGE'},
    {'name': 'Other', 'value': 'OTHER'},
  ];


  @override
  void initState() {
    super.initState();
    // Add listeners to update progress when fields change
    _fullNameController.addListener(_updateProgress);
    _phoneController.addListener(_updateProgress);
    _passwordController.addListener(_updateProgress);
  }

  @override
  void dispose() {
    _fullNameController.removeListener(_updateProgress);
    _phoneController.removeListener(_updateProgress);
    _passwordController.removeListener(_updateProgress);
    _fullNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Calculate progress based on filled fields
  /// Each field contributes 20% (5 fields total: name, phone, password, department, document)
  double get _progress {
    double progress = 0.0;
    
    // Name filled (20%)
    if (_fullNameController.text.trim().isNotEmpty) {
      progress += 0.2;
    }
    
    // Phone filled (20%)
    if (_phoneController.text.trim().isNotEmpty) {
      progress += 0.2;
    }
    
    // Password filled (20%)
    if (_passwordController.text.trim().isNotEmpty) {
      progress += 0.2;
    }
    
    // Department selected (20%)
    if (_selectedDepartment != null && _selectedDepartment!.isNotEmpty) {
      progress += 0.2;
    }
    
    // Document uploaded (20%)
    if (_selectedDocument != null || _selectedDocumentBytes != null) {
      progress += 0.2;
    }
    
    return progress.clamp(0.0, 1.0);
  }

  /// Update progress (triggers rebuild)
  void _updateProgress() {
    setState(() {
      // Progress is calculated via getter, just trigger rebuild
    });
  }

  /// Generate random password
  String _generateRandomPassword() {
    const String upperCase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String lowerCase = 'abcdefghijklmnopqrstuvwxyz';
    const String numbers = '0123456789';
    const String special = '!@#\$%^&*()_+-=[]{}|;:,.<>?';
    const String allChars = upperCase + lowerCase + numbers + special;
    
    final Random random = Random.secure();
    final StringBuffer password = StringBuffer();
    
    // Ensure at least one of each type
    password.write(upperCase[random.nextInt(upperCase.length)]);
    password.write(lowerCase[random.nextInt(lowerCase.length)]);
    password.write(numbers[random.nextInt(numbers.length)]);
    password.write(special[random.nextInt(special.length)]);
    
    // Fill the rest randomly (total length 12)
    for (int i = 4; i < 12; i++) {
      password.write(allChars[random.nextInt(allChars.length)]);
    }
    
    // Shuffle the password
    final List<String> chars = password.toString().split('');
    chars.shuffle(random);
    return chars.join();
  }

  void _autoGeneratePassword() {
    setState(() {
      _passwordController.text = _generateRandomPassword();
      _updateProgress();
    });
  }

  /// Pick document from device (supports images and PDFs)
  Future<void> _pickDocument() async {
    try {
      if (kIsWeb) {
        // For web, use file_picker
        file_picker.FilePickerResult? result = await file_picker.FilePicker.platform.pickFiles(
          type: file_picker.FileType.custom,
          allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'],
        );

        if (result != null && result.files.single.bytes != null) {
          setState(() {
            _selectedDocumentBytes = result.files.single.bytes;
            _selectedDocument = null;
            _selectedDocumentName = result.files.single.name;
            _updateProgress();
          });
        }
      } else {
        // For mobile, use file_picker for PDFs and image_picker for images
        // Show dialog to choose between image and PDF
        final source = await showModalBottomSheet<String>(
          context: context,
          builder: (context) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.image),
                  title: const Text('Pick Image'),
                  onTap: () => Navigator.pop(context, 'image'),
                ),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf),
                  title: const Text('Pick PDF'),
                  onTap: () => Navigator.pop(context, 'pdf'),
                ),
              ],
            ),
          ),
        );

        if (source == null) return;

        if (source == 'image') {
          // Use image picker for images
          final XFile? pickedFile = await _imagePicker.pickImage(
            source: ImageSource.gallery,
            maxWidth: 1920,
            maxHeight: 1920,
            imageQuality: 85,
          );

          if (pickedFile != null) {
            setState(() {
              _selectedDocument = File(pickedFile.path);
              _selectedDocumentBytes = null;
              _selectedDocumentName = pickedFile.name;
              _updateProgress();
            });
          }
        } else {
          // Use file picker for PDFs
          file_picker.FilePickerResult? result = await file_picker.FilePicker.platform.pickFiles(
            type: file_picker.FileType.custom,
            allowedExtensions: ['pdf'],
          );

          if (result != null && result.files.single.path != null) {
            setState(() {
              _selectedDocument = File(result.files.single.path!);
              _selectedDocumentBytes = null;
              _selectedDocumentName = result.files.single.name;
              _updateProgress();
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick document: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  /// Handle agent creation
  Future<void> _handleCreate() async {
    // Validate inputs
    if (_fullNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter agent\'s full name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter phone number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedDepartment == null || _selectedDepartment!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a department'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please generate a password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedDocument == null && _selectedDocumentBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a document'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? documentPath;

      // Upload document first (supports both images and PDFs)
      if (_selectedDocument != null || _selectedDocumentBytes != null) {
        final isPdf = _selectedDocumentName?.toLowerCase().endsWith('.pdf') ?? false;
        
        ApiResponse<Map<String, dynamic>> uploadResponse;
        
        if (kIsWeb) {
          // For web, use bytes upload
          final fileName = _selectedDocumentName ?? (isPdf ? 'document.pdf' : 'document.jpg');
          uploadResponse = await _api.uploadFileFromBytes<Map<String, dynamic>>(
            '/api/images/upload',
            bytes: _selectedDocumentBytes!,
            fileName: fileName,
            fieldName: 'file',
          );
        } else {
          // For mobile, use file upload
          // Use io.File to explicitly reference dart:io.File
          // ignore: avoid_dynamic_calls
          final filePath = (_selectedDocument as dynamic).path as String;
          final file = io.File(filePath);
          uploadResponse = await _api.uploadFile<Map<String, dynamic>>(
            '/api/images/upload',
            file: file,
            fieldName: 'file',
          );
        }

        if (!uploadResponse.success) {
          setState(() => _isLoading = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(uploadResponse.error ?? 'Failed to upload document. Please try again.'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
          return;
        }

        // Extract path from response
        if (uploadResponse.data != null) {
          documentPath = uploadResponse.data!['url'] as String?;
        }
      }

      if (documentPath == null) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to get document path. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Create agent with document path
      final response = await _agentService.createAgent(
        name: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text.trim(),
        document: documentPath,
        department: _selectedDepartment!,
      );

      setState(() => _isLoading = false);

      // Extract message from response
      String? message;
      bool isSuccess = false;
      
      if (response.data != null) {
        // New API format: response has success and message fields in data
        final responseData = response.data as Map<String, dynamic>;
        isSuccess = responseData['success'] == true;
        message = responseData['message'] as String?;
      } else {
        // Fallback to ApiResponse wrapper
        isSuccess = response.success;
        message = response.error ?? 'Failed to create agent. Please try again.';
      }

      if (mounted) {
        if (isSuccess) {
          // Show success dialog with message
          _showMessageDialog(message ?? 'Agent created successfully', true);
        } else {
          // Show error message in dialog (not snackbar)
          _showMessageDialog(message ?? 'Failed to create agent. Please try again.', false);
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Add New Agent',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Progress bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      widthFactor: _progress,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF136AF6), Color(0xFF0D5AE0)],
                          ),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF136AF6).withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Personal Information
                  _buildSection(
                    title: 'Personal Information',
                    children: [
                      _buildTextField(
                        label: 'Full Name',
                        controller: _fullNameController,
                        hintText: 'Enter agent\'s full name',
                      ),
                      _buildTextField(
                        label: 'Phone Number',
                        controller: _phoneController,
                        hintText: 'Enter phone number',
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),

                  // Department & Role
                  _buildSection(
                    title: 'Department & Role',
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Department',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF111318),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFDBDFE6),
                                  width: 1,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedDepartment ?? '',
                                  isExpanded: true,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF111318),
                                  ),
                                  items: _departments.map((dept) {
                                    return DropdownMenuItem(
                                      value: dept['value']!,
                                      child: Text(dept['name']!),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedDepartment = value;
                                      _updateProgress();
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Password',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF111318),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F7F8),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFFDBDFE6),
                                        width: 1,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: TextField(
                                        controller: _passwordController,
                                        enabled: false,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF111318),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                TextButton(
                                  onPressed: _autoGeneratePassword,
                                  child: const Text(
                                    'Auto-generate',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF136AF6),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Onboarding Documents
                  _buildSection(
                    title: 'Onboarding Documents',
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Agent Documents',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF111318),
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: _pickDocument,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFFDBDFE6),
                                    width: 2,
                                    style: BorderStyle.solid,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: (_selectedDocument != null || _selectedDocumentBytes != null)
                                    ? Column(
                                        children: [
                                          Icon(
                                            _selectedDocumentName?.toLowerCase().endsWith('.pdf') ?? false
                                                ? Icons.picture_as_pdf
                                                : Icons.check_circle,
                                            size: 48,
                                            color: _selectedDocumentName?.toLowerCase().endsWith('.pdf') ?? false
                                                ? Colors.red
                                                : Colors.green,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            _selectedDocumentName ?? 'Document selected',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF111318),
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                _selectedDocument = null;
                                                _selectedDocumentBytes = null;
                                                _selectedDocumentName = null;
                                                _updateProgress();
                                              });
                                            },
                                            child: const Text(
                                              'Remove',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        children: [
                                          const Icon(
                                            Icons.cloud_upload,
                                            size: 48,
                                            color: Color(0xFF9CA3AF),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Tap to upload document',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF5F708C),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          const Text(
                                            'Supported formats: PDF, JPG, PNG, GIF, WEBP, BMP',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF5F708C),
                                            ),
                                          ),
                                        ],
                                      ),
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

            // Bottom button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF136AF6), Color(0xFF0D5AE0)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF136AF6).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleCreate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Create',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 24, bottom: 12),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111318),
                letterSpacing: -0.015,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7F8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 15,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
              ),
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }



  void _showMessageDialog(String message, bool isSuccess) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              size: 64,
              color: isSuccess ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: isSuccess ? const Color(0xFF111318) : Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close modal
                  if (isSuccess) {
                    Navigator.of(context).pop(); // Go back to admin home
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSuccess ? const Color(0xFF136AF6) : Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isSuccess ? 'Done' : 'OK',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

