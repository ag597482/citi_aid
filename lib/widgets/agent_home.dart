import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'agent_profile.dart';
import 'complaint_detail.dart';
import 'feed_page.dart'; // Import Complaint class
import '../services/complaint_service.dart';
import '../services/auth_service.dart';
import '../api/api_config.dart';
import 'dart:io' if (dart.library.html) '../io_stub.dart' show File;

class AgentHomePage extends StatefulWidget {
  const AgentHomePage({super.key});

  @override
  State<AgentHomePage> createState() => _AgentHomePageState();
}

class _AgentHomePageState extends State<AgentHomePage> {
  String _selectedTab = 'Assigned';
  final ComplaintService _complaintService = ComplaintService();
  final AuthService _authService = AuthService();
  final ImagePicker _imagePicker = ImagePicker();
  List<Complaint> _allComplaints = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  /// Load complaints from API for the logged-in agent
  Future<void> _loadComplaints() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get agent ID from stored user
      final user = await _authService.getStoredUser();
      if (user == null || !user.isAgent) {
        setState(() {
          _errorMessage = 'Agent not logged in';
          _isLoading = false;
        });
        return;
      }

      // Fetch complaints for this agent
      final response = await _complaintService.getAgentComplaints(user.id);

      if (response.success && response.data != null) {
        final complaintsList = response.data as List;
        setState(() {
          _allComplaints = complaintsList
              .map((json) => Complaint.fromJson(json as Map<String, dynamic>))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.error ?? 'Failed to load complaints';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  /// Get full image URL from beforePhoto path
  Future<String?> _getImageUrl(String? beforePhoto) async {
    if (beforePhoto == null || beforePhoto.isEmpty) {
      return null;
    }
    
    // If it's already a full URL, return as is
    if (beforePhoto.startsWith('http://') || beforePhoto.startsWith('https://')) {
      return beforePhoto;
    }
    
    // If it's a path, construct full URL
    final baseUrl = await ApiConfig.getBaseUrl();
    // Remove leading slash if present to avoid double slashes
    final cleanPath = beforePhoto.startsWith('/') ? beforePhoto.substring(1) : beforePhoto;
    return '$baseUrl/$cleanPath';
  }

  /// Get filtered complaints based on selected tab
  List<Complaint> get _filteredComplaints {
    switch (_selectedTab) {
      case 'Assigned':
        return _allComplaints
            .where((c) => c.status.toUpperCase() == 'AGENT_ASSIGNED' || c.status.toUpperCase() == 'ASSIGNED')
            .toList();
      case 'In-Progress':
        return _allComplaints
            .where((c) => c.status.toUpperCase() == 'IN_PROGRESS' || c.status.toUpperCase() == 'IN-PROGRESS')
            .toList();
      case 'Completed':
        return _allComplaints
            .where((c) {
              final status = c.status.toUpperCase();
              return status == 'COMPLETED' || status == 'FIXED';
            })
            .toList();
      default:
        return [];
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'electricity':
        return const Color(0xFF136AF6); // primary blue
      case 'potholes':
        return const Color(0xFFFF9500); // warning orange
      case 'drainage':
        return const Color(0xFF136AF6); // primary blue
      case 'garbage':
        return const Color(0xFFFF3B30); // danger red
      default:
        return const Color(0xFF64748B); // gray
    }
  }

  /// Get icon for department
  IconData _getDepartmentIcon(String department) {
    switch (department.toUpperCase()) {
      case 'ELECTRICITY':
        return Icons.electric_bolt;
      case 'POTHOLES':
        return Icons.warning;
      case 'DRAINAGE':
        return Icons.water_drop;
      case 'GARBAGE':
        return Icons.delete;
      default:
        return Icons.more_horiz;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'IN_PROGRESS':
      case 'IN-PROGRESS':
        return const Color(0xFFFF9500); // warning
      case 'RAISED':
        return const Color(0xFF64748B); // gray
      case 'ASSIGNED':
      case 'AGENT_ASSIGNED':
        return const Color(0xFF136AF6); // primary
      case 'COMPLETED':
      case 'FIXED':
        return const Color(0xFF34C759); // success
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Icons.priority_high;
      case 'medium':
        return Icons.flag;
      case 'low':
        return Icons.remove;
      default:
        return Icons.flag;
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
              child: Column(
                children: [
                  // Search bar with profile icon
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 20),
                                child: Icon(
                                  Icons.search,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Search by ID, Street...',
                                    hintStyle: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 15,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.filter_list,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.map,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Profile icon
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: IconButton(
                          onPressed: () {
                            // Navigate to agent profile page
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const AgentProfilePage(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tabs
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTab('Assigned', _selectedTab == 'Assigned'),
                  ),
                  Expanded(
                    child: _buildTab('In-Progress', _selectedTab == 'In-Progress'),
                  ),
                  Expanded(
                    child: _buildTab('Completed', _selectedTab == 'Completed'),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF136AF6),
                      ),
                    )
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF1C1C1E),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadComplaints,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _filteredComplaints.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: _loadComplaints,
                              child: _buildComplaintsList(),
                            ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildTab(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF136AF6), Color(0xFF0D5AE0)],
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComplaintsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _filteredComplaints.length,
      itemBuilder: (context, index) {
        final complaint = _filteredComplaints[index];
        return _buildComplaintCard(complaint);
      },
    );
  }

  Widget _buildComplaintCard(Complaint complaint) {
    final bool isAgentAssigned = complaint.status.toUpperCase() == 'AGENT_ASSIGNED' || 
                                  complaint.status.toUpperCase() == 'ASSIGNED';
    final bool isInProgress = complaint.status.toUpperCase() == 'IN_PROGRESS' || 
                              complaint.status.toUpperCase() == 'IN-PROGRESS';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Card content (clickable to open details)
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ComplaintDetailPage(
                    complaintId: complaint.id,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor(complaint.categoryDisplay).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: _getCategoryColor(complaint.categoryDisplay).withOpacity(0.2),
                                    ),
                                  ),
                                  child: Text(
                                    complaint.categoryDisplay,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: _getCategoryColor(complaint.categoryDisplay),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  _getPriorityIcon(complaint.priorityDisplay),
                                  color: complaint.priorityDisplay == 'high' 
                                      ? const Color(0xFFFF3B30) 
                                      : const Color(0xFFFF9500),
                                  size: 16,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              complaint.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              complaint.description,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    complaint.location,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  '·',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  complaint.timePosted,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                            if (complaint.createdBy != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Created by ${complaint.createdBy}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Image or category icon placeholder
                      FutureBuilder<String?>(
                        future: _getImageUrl(complaint.beforePhoto),
                        builder: (context, snapshot) {
                          final imageUrl = snapshot.data;
                          
                          return Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: _getCategoryColor(complaint.categoryDisplay).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _getCategoryColor(complaint.categoryDisplay).withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: imageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      imageUrl,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        // Fallback to icon if image fails to load
                                        return Icon(
                                          _getDepartmentIcon(complaint.department),
                                          color: _getCategoryColor(complaint.categoryDisplay),
                                          size: 40,
                                        );
                                      },
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded /
                                                    loadingProgress.expectedTotalBytes!
                                                : null,
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              _getCategoryColor(complaint.categoryDisplay),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : Icon(
                                    _getDepartmentIcon(complaint.department),
                                    color: _getCategoryColor(complaint.categoryDisplay),
                                    size: 40,
                                  ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 1,
                    color: const Color(0xFFE2E8F0),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(complaint.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          complaint.statusDisplay,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _getStatusColor(complaint.status),
                          ),
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
                    color: Color(0xFFD1D1D6),
                    width: 0.5,
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
                          onPressed: () => _handleStartProgress(complaint.id),
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
                          onPressed: () => _showCloseComplaintDialog(complaint.id),
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
          // Reload complaints
          _loadComplaints();
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
                                // Reload complaints
                                _loadComplaints();
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No complaints',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1C1E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No ${_selectedTab.toLowerCase()} complaints found.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
