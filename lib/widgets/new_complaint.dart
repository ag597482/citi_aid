import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/complaint_service.dart';

// Import File only for non-web platforms
// On web, we'll never use File, only bytes
import 'dart:io' if (dart.library.html) '../io_stub.dart' show File;

class NewComplaintPage extends StatefulWidget {
  const NewComplaintPage({super.key});

  @override
  State<NewComplaintPage> createState() => _NewComplaintPageState();
}

class _NewComplaintPageState extends State<NewComplaintPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _targetFundController = TextEditingController();
  String _selectedSeverity = 'MEDIUM';
  bool _isLoading = false;
  bool _crowdFundingEnabled = false;
  // Only use File on non-web platforms - use dynamic to avoid type conflicts
  dynamic _selectedImage; // dart:io.File on non-web, null on web
  Uint8List? _selectedImageBytes; // For web compatibility
  final _complaintService = ComplaintService();
  final _imagePicker = ImagePicker();

  // Map category names to department values (backend expects uppercase)
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Electricity', 'department': 'ELECTRICITY', 'icon': Icons.electric_bolt, 'selected': true},
    {'name': 'Potholes', 'department': 'POTHOLES', 'icon': Icons.warning, 'selected': false},
    {'name': 'Drainage', 'department': 'DRAINAGE', 'icon': Icons.water_drop, 'selected': false},
    {'name': 'Garbage', 'department': 'GARBAGE', 'icon': Icons.delete, 'selected': false},
    {'name': 'Other', 'department': 'OTHER', 'icon': Icons.more_horiz, 'selected': false},
  ];

  @override
  void initState() {
    super.initState();
    // Add listeners to update progress when fields change
    _titleController.addListener(_updateProgress);
    _descriptionController.addListener(_updateProgress);
    _locationController.addListener(_updateProgress);
  }

  @override
  void dispose() {
    _titleController.removeListener(_updateProgress);
    _descriptionController.removeListener(_updateProgress);
    _locationController.removeListener(_updateProgress);
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _targetFundController.dispose();
    super.dispose();
  }

  /// Calculate progress based on filled fields
  /// Each field contributes 20% (5 fields total: title, description, location, department, severity)
  double get _progress {
    double progress = 0.0;
    
    // Title filled (20%)
    if (_titleController.text.trim().isNotEmpty) {
      progress += 0.2;
    }
    
    // Description filled (20%)
    if (_descriptionController.text.trim().isNotEmpty) {
      progress += 0.2;
    }
    
    // Location filled (20%)
    if (_locationController.text.trim().isNotEmpty) {
      progress += 0.2;
    }
    
    // Department selected (20%)
    if (_selectedDepartment != null) {
      progress += 0.2;
    }
    
    // Severity selected (20% - always selected, but included for completeness)
    if (_selectedSeverity.isNotEmpty) {
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

  /// Get selected department value
  String? get _selectedDepartment {
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
          // For web, we need to read bytes
          setState(() {
            _selectedImageBytes = null; // Will be loaded asynchronously
            _selectedImage = null;
          });
          _loadImageBytes(pickedFile);
        } else {
          // Only use File on non-web platforms
          // Import dart:io directly for File creation to avoid type issues
          setState(() {
            _selectedImage = File(pickedFile.path);
            _selectedImageBytes = null;
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

  /// Handle complaint submission
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

    final department = _selectedDepartment;
    if (department == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a department'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Crowdfunding: require a funding goal strictly greater than ₹1
    if (_crowdFundingEnabled) {
      final targetText = _targetFundController.text.trim();
      if (targetText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a crowdfunding goal amount'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      final targetParsed = double.tryParse(targetText);
      if (targetParsed == null || targetParsed <= 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Crowdfunding goal must be greater than ₹1'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl;

      // Upload image first if one is selected
      if (_selectedImage != null || _selectedImageBytes != null) {
        // On web, only use bytes. On non-web, only use File.
        // Use dynamic cast to avoid type conflicts between stub and real File
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

        // Extract URL from response
        if (uploadResponse.data != null) {
          imageUrl = uploadResponse.data!['url'] as String?;
        }
      }

      // Parse target fund if crowdfunding is enabled
      double? targetFund;
      if (_crowdFundingEnabled && _targetFundController.text.trim().isNotEmpty) {
        final parsed = double.tryParse(_targetFundController.text.trim());
        if (parsed != null && parsed > 1) {
          targetFund = parsed;
        }
      }

      // Create complaint with image URL
      final response = await _complaintService.createComplaint(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        department: department,
        severity: _selectedSeverity,
        beforePhoto: imageUrl,
        crowdFundingEnabled: _crowdFundingEnabled,
        targetFund: targetFund,
      );

      setState(() => _isLoading = false);

      if (response.success) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Complaint created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate back to previous page
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.error ?? 'Failed to create complaint. Please try again.'),
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
                        'Create Complaint',
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
                    // Progress percentage text
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
                    // Progress bar
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
                          'What\'s the problem?',
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
                              // Update progress when department is selected
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

                    const SizedBox(height: 16),

                    // AI analyzing message
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                const Color(0xFF136AF6),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'AI analyzing category...',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
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

                        // Crowdfunding section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: _crowdFundingEnabled,
                                  onChanged: (value) {
                                    setState(() {
                                      _crowdFundingEnabled = value ?? false;
                                      if (!_crowdFundingEnabled) {
                                        _targetFundController.clear();
                                      }
                                    });
                                  },
                                  activeColor: const Color(0xFF136AF6),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Enable Crowdfunding',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1E293B),
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Allow others to contribute funds to help resolve this issue',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (_crowdFundingEnabled) ...[
                              const SizedBox(height: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Target Fund Amount (₹)',
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
                                      controller: _targetFundController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: const InputDecoration(
                                        hintText: 'Enter target amount (e.g., 5000)',
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
                                          Icons.currency_rupee,
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
                                  const SizedBox(height: 8),
                                  Text(
                                    'Must be greater than ₹1',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Image upload section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Add Photo (Optional)',
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

                    const SizedBox(height: 16),

                    // Duplicate warning
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF136AF6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: const Border(
                          left: BorderSide(
                            color: Color(0xFF136AF6),
                            width: 4,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Possible Duplicate',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF136AF6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF136AF6),
                              ),
                              children: [
                                TextSpan(text: 'We found a similar complaint: "Frequent power cuts on Elm Street". Is this the same issue? '),
                                TextSpan(
                                  text: 'View complaint',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
                    'Submit Complaint',
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
