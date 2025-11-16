import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/complaint_service.dart';
import '../api/api_config.dart';

// Import File only for non-web platforms
// On web, we'll never use File, only bytes
import 'dart:io' if (dart.library.html) '../io_stub.dart' show File;

class EditComplaintPage extends StatefulWidget {
  final String complaintId;
  final Map<String, dynamic> complaint;

  const EditComplaintPage({
    super.key,
    required this.complaintId,
    required this.complaint,
  });

  @override
  State<EditComplaintPage> createState() => _EditComplaintPageState();
}

class _EditComplaintPageState extends State<EditComplaintPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late String _selectedSeverity;
  String? _selectedDepartment;
  bool _isLoading = false;
  dynamic _selectedImage; // dart:io.File on non-web, null on web
  Uint8List? _selectedImageBytes; // For web compatibility
  String? _existingImageUrl; // URL of existing image
  bool _imageChanged = false;
  final _complaintService = ComplaintService();
  final _imagePicker = ImagePicker();
  String? _baseUrl;

  // Map category names to department values (backend expects uppercase)
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Electricity', 'department': 'ELECTRICITY', 'icon': Icons.electric_bolt, 'selected': false},
    {'name': 'Potholes', 'department': 'POTHOLES', 'icon': Icons.warning, 'selected': false},
    {'name': 'Drainage', 'department': 'DRAINAGE', 'icon': Icons.water_drop, 'selected': false},
    {'name': 'Garbage', 'department': 'GARBAGE', 'icon': Icons.delete, 'selected': false},
    {'name': 'Other', 'department': 'OTHER', 'icon': Icons.more_horiz, 'selected': false},
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with existing data
    _titleController = TextEditingController(text: widget.complaint['title'] ?? '');
    _descriptionController = TextEditingController(text: widget.complaint['description'] ?? '');
    _locationController = TextEditingController(text: widget.complaint['location'] ?? '');
    _selectedSeverity = widget.complaint['severity'] ?? 'MEDIUM';
    _selectedDepartment = widget.complaint['department'] ?? null;
    _existingImageUrl = widget.complaint['beforePhoto'] as String?;
    
    // Set selected category
    if (_selectedDepartment != null) {
      for (var i = 0; i < _categories.length; i++) {
        if (_categories[i]['department'] == _selectedDepartment) {
          _categories[i]['selected'] = true;
          break;
        }
      }
    }
    
    // Add listeners to update progress when fields change
    _titleController.addListener(_updateProgress);
    _descriptionController.addListener(_updateProgress);
    _locationController.addListener(_updateProgress);
    
    _loadBaseUrl();
  }

  Future<void> _loadBaseUrl() async {
    final url = await ApiConfig.getBaseUrl();
    setState(() {
      _baseUrl = url;
    });
  }

  String _getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    final baseUrl = _baseUrl ?? 'http://localhost:8080';
    return '$baseUrl$imagePath';
  }

  @override
  void dispose() {
    _titleController.removeListener(_updateProgress);
    _descriptionController.removeListener(_updateProgress);
    _locationController.removeListener(_updateProgress);
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  /// Calculate progress based on filled fields
  double get _progress {
    double progress = 0.0;
    
    if (_titleController.text.trim().isNotEmpty) progress += 0.2;
    if (_descriptionController.text.trim().isNotEmpty) progress += 0.2;
    if (_locationController.text.trim().isNotEmpty) progress += 0.2;
    if (_selectedDepartment != null) progress += 0.2;
    if (_selectedSeverity.isNotEmpty) progress += 0.2;
    
    return progress.clamp(0.0, 1.0);
  }

  void _updateProgress() {
    setState(() {});
  }

  /// Get selected department value
  String? get _currentDepartment {
    for (var cat in _categories) {
      if (cat['selected'] == true) {
        return cat['department'] as String;
      }
    }
    return null;
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
            _selectedImageBytes = null;
            _selectedImage = null;
            _imageChanged = true;
          });
          _loadImageBytes(pickedFile);
        } else {
          setState(() {
            _selectedImage = File(pickedFile.path);
            _selectedImageBytes = null;
            _imageChanged = true;
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

  /// Load image bytes for web
  Future<void> _loadImageBytes(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
      });
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

  /// Handle complaint update
  Future<void> _handleSubmit() async {
    // Validate inputs
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a description'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a location'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final department = _currentDepartment;
    if (department == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a department'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl;

      // Handle image upload/removal
      if (_imageChanged) {
        // User changed the image (either added new or removed existing)
        if (_selectedImage != null || _selectedImageBytes != null) {
          // User selected a new image - upload it
          final uploadResponse = kIsWeb
              ? await _complaintService.uploadImage(
                  imageFile: null,
                  imageBytes: _selectedImageBytes,
                  fileName: _selectedImageBytes != null ? 'image.jpg' : null,
                )
              : await _complaintService.uploadImage(
                  imageFile: _selectedImage as dynamic,
                  imageBytes: null,
                  fileName: null,
                );

          if (!uploadResponse.success) {
            setState(() => _isLoading = false);
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

          if (uploadResponse.data != null) {
            imageUrl = uploadResponse.data!['url'] as String?;
          }
        } else {
          // User removed the image - set to null (will be sent as null to clear it)
          imageUrl = null;
        }
      } else {
        // Image not changed - preserve existing image URL
        imageUrl = _existingImageUrl;
      }

      // Extract agentId from existing complaint
      String? agentId;
      if (widget.complaint['agent'] != null) {
        if (widget.complaint['agent'] is Map<String, dynamic>) {
          agentId = (widget.complaint['agent'] as Map<String, dynamic>)['id'] as String?;
        } else if (widget.complaint['agent'] is String) {
          agentId = widget.complaint['agent'] as String;
        }
      }

      // Update complaint - only send fields that can be edited from UI
      // Preserve other fields (status, agentId, afterPhoto) from existing complaint
      final response = await _complaintService.updateComplaint(
        id: widget.complaintId,
        // Editable fields from UI
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        department: department,
        severity: _selectedSeverity,
        beforePhoto: imageUrl, // New image, existing image, or null if removed
        // Preserve existing values for fields not editable from UI
        status: widget.complaint['status'] as String?,
        agentId: agentId,
        afterPhoto: widget.complaint['afterPhoto'] as String?,
      );

      setState(() => _isLoading = false);

      if (response.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Complaint updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.error ?? 'Failed to update complaint. Please try again.'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF136AF6),
              const Color(0xFF136AF6).withOpacity(0.8),
              const Color(0xFF136AF6).withOpacity(0.6),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Back button and header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        'Edit Complaint',
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

              const SizedBox(height: 20),
              
              // Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${(_progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _progress,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Form Card
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title section
                        const Text(
                          'Edit Complaint',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Title input
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Title',
                              style: TextStyle(
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
                                controller: _titleController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter a brief title',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 15,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 18,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.title,
                                    color: Color(0xFF136AF6),
                                    size: 22,
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

                        const SizedBox(height: 24),

                        // Category selection
                        Text(
                          'What type of issue is this?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF111318),
                            letterSpacing: -0.015,
                          ),
                        ),
                        const SizedBox(height: 8),

                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1,
                          ),
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            final isSelected = category['selected'] as bool;
                            
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  for (var cat in _categories) {
                                    cat['selected'] = false;
                                  }
                                  _categories[index]['selected'] = true;
                                  _selectedDepartment = category['department'] as String;
                                  _updateProgress();
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? const Color(0xFF136AF6).withOpacity(0.1)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected 
                                        ? const Color(0xFF136AF6)
                                        : const Color(0xFFD1D5DB),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      category['icon'] as IconData,
                                      color: isSelected 
                                          ? const Color(0xFF136AF6)
                                          : const Color(0xFF6B7280),
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      category['name'] as String,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isSelected 
                                            ? const Color(0xFF136AF6)
                                            : const Color(0xFF374151),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // Severity selection
                        Text(
                          'How urgent is this?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF111318),
                            letterSpacing: -0.015,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedSeverity = 'LOW';
                                    _updateProgress();
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _selectedSeverity == 'LOW' 
                                        ? const Color(0xFFFF9500).withOpacity(0.2)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _selectedSeverity == 'LOW' 
                                          ? const Color(0xFFFF9500)
                                          : const Color(0xFFD1D5DB),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    'Low',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: _selectedSeverity == 'LOW' 
                                          ? const Color(0xFFFF9500)
                                          : const Color(0xFF374151),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedSeverity = 'MEDIUM';
                                    _updateProgress();
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _selectedSeverity == 'MEDIUM' 
                                        ? const Color(0xFFFF9500).withOpacity(0.2)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _selectedSeverity == 'MEDIUM' 
                                          ? const Color(0xFFFF9500)
                                          : const Color(0xFFD1D5DB),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    'Medium',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: _selectedSeverity == 'MEDIUM' 
                                          ? const Color(0xFFFF9500)
                                          : const Color(0xFF374151),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedSeverity = 'HIGH';
                                    _updateProgress();
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _selectedSeverity == 'HIGH' 
                                        ? const Color(0xFFFF9500).withOpacity(0.2)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _selectedSeverity == 'HIGH' 
                                          ? const Color(0xFFFF9500)
                                          : const Color(0xFFD1D5DB),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    'High',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: _selectedSeverity == 'HIGH' 
                                          ? const Color(0xFFFF9500)
                                          : const Color(0xFF374151),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Description input
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F7F8),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                  width: 1.5,
                                ),
                              ),
                              child: TextField(
                                controller: _descriptionController,
                                maxLines: 4,
                                decoration: const InputDecoration(
                                  hintText: 'Tell us more about the issue',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 15,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(20),
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.only(bottom: 60),
                                    child: Icon(
                                      Icons.description_outlined,
                                      color: Color(0xFF136AF6),
                                      size: 22,
                                    ),
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

                        const SizedBox(height: 24),

                        // Location input
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Location',
                              style: TextStyle(
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
                                controller: _locationController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter location (e.g., new orr in hsr)',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 15,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 18,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.location_on,
                                    color: Color(0xFF136AF6),
                                    size: 22,
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

                        const SizedBox(height: 24),

                        // Image upload section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Update Photo (Optional)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: _showImageSourceDialog,
                              child: Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F7F8),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                    width: 1.5,
                                  ),
                                ),
                                child: (_selectedImage != null || _selectedImageBytes != null)
                                    ? Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(16),
                                            child: kIsWeb && _selectedImageBytes != null
                                                ? Image.memory(
                                                    _selectedImageBytes!,
                                                    width: double.infinity,
                                                    height: 120,
                                                    fit: BoxFit.cover,
                                                  )
                                                : _selectedImage != null && !kIsWeb
                                                    ? Image.file(
                                                        _selectedImage as dynamic,
                                                        width: double.infinity,
                                                        height: 120,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : const SizedBox(),
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.6),
                                                shape: BoxShape.circle,
                                              ),
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _selectedImage = null;
                                                    _selectedImageBytes = null;
                                                    _imageChanged = false;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : _existingImageUrl != null && !_imageChanged
                                        ? Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(16),
                                                child: Image.network(
                                                  _getImageUrl(_existingImageUrl),
                                                  width: double.infinity,
                                                  height: 120,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Container(
                                                      color: Colors.grey[300],
                                                      child: const Icon(Icons.broken_image),
                                                    );
                                                  },
                                                ),
                                              ),
                                              Positioned(
                                                top: 8,
                                                right: 8,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.black.withOpacity(0.6),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: IconButton(
                                                    icon: const Icon(
                                                      Icons.close,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        _existingImageUrl = null;
                                                        _imageChanged = true;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        : Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.add_photo_alternate,
                                                color: const Color(0xFF136AF6),
                                                size: 32,
                                              ),
                                              const SizedBox(width: 12),
                                              const Text(
                                                'Tap to add photo',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Color(0xFF94A3B8),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
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
              colors: [
                Color(0xFF136AF6),
                Color(0xFF0D5AE0),
              ],
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
            onPressed: _isLoading ? null : _handleSubmit,
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
                    'Update Complaint',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

