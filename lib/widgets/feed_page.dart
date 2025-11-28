import 'package:flutter/material.dart';
import 'new_complaint.dart';
import 'customer_profile.dart';
import 'complaint_detail.dart';
import '../services/complaint_service.dart';
import '../api/api_config.dart';

class Complaint {
  final String id;
  final String title;
  final String description;
  final String location;
  final String department;
  final String severity;
  final String status;
  final String? beforePhoto;
  final String? afterPhoto;
  final String? agent;
  final String? createdBy; // Name of the user who created the complaint
  final DateTime createdAt;
  final DateTime? assignedAt;
  final DateTime? completedAt;

  Complaint({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.department,
    required this.severity,
    required this.status,
    this.beforePhoto,
    this.afterPhoto,
    this.agent,
    this.createdBy,
    required this.createdAt,
    this.assignedAt,
    this.completedAt,
  });

  /// Create Complaint from API response JSON
  factory Complaint.fromJson(Map<String, dynamic> json) {
    // Extract customer name from customer object
    String? createdBy;
    if (json['customer'] != null) {
      if (json['customer'] is Map<String, dynamic>) {
        final customer = json['customer'] as Map<String, dynamic>;
        createdBy = customer['name'] as String?;
      } else if (json['customer'] is String) {
        createdBy = json['customer'] as String;
      }
    }
    
    // Extract agent - can be either a Map or String
    String? agent;
    if (json['agent'] != null) {
      if (json['agent'] is Map<String, dynamic>) {
        final agentMap = json['agent'] as Map<String, dynamic>;
        agent = agentMap['name'] as String? ?? agentMap['id'] as String?;
      } else if (json['agent'] is String) {
        agent = json['agent'] as String;
      }
    }
    
    // Safely parse dates
    DateTime? parseDate(dynamic dateValue) {
      if (dateValue == null) return null;
      if (dateValue is String) {
        try {
          return DateTime.parse(dateValue);
        } catch (e) {
          return null;
        }
      }
      return null;
    }
    
    return Complaint(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      severity: json['severity']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      beforePhoto: json['beforePhoto']?.toString(),
      afterPhoto: json['afterPhoto']?.toString(),
      agent: agent,
      createdBy: createdBy,
      createdAt: parseDate(json['createdAt']) ?? DateTime.now(),
      assignedAt: parseDate(json['assignedAt']),
      completedAt: parseDate(json['completedAt']),
    );
  }

  /// Get formatted time ago string
  String get timePosted {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Get category display name from department
  String get categoryDisplay {
    switch (department.toUpperCase()) {
      case 'ELECTRICITY':
        return 'Electricity';
      case 'POTHOLES':
        return 'Potholes';
      case 'DRAINAGE':
        return 'Drainage';
      case 'GARBAGE':
        return 'Garbage';
      default:
        return department;
    }
  }

  /// Get priority display from severity
  String get priorityDisplay {
    switch (severity.toUpperCase()) {
      case 'HIGH':
        return 'high';
      case 'MEDIUM':
        return 'medium';
      case 'LOW':
        return 'low';
      default:
        return severity.toLowerCase();
    }
  }

  /// Get status display name
  String get statusDisplay {
    switch (status.toUpperCase()) {
      case 'RAISED':
        return 'Raised';
      case 'IN_PROGRESS':
      case 'IN-PROGRESS':
        return 'In-progress';
      case 'ASSIGNED':
        return 'Agent Assigned';
      case 'COMPLETED':
      case 'FIXED':
        return 'Fixed';
      default:
        return status;
    }
  }

  /// Check if complaint is fixed
  bool get isFixed => status.toUpperCase() == 'COMPLETED' || 
                      status.toUpperCase() == 'FIXED' ||
                      completedAt != null;
}

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final TextEditingController _searchController = TextEditingController();
  final _complaintService = ComplaintService();
  
  List<Complaint> _complaints = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Load complaints from API
  Future<void> _loadComplaints() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _complaintService.getAllComplaints();

      if (response.success && response.data != null) {
        final complaintsList = response.data as List;
        setState(() {
          _complaints = complaintsList
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

  /// Get full image URL from beforePhoto path
  /// beforePhoto might be a path like "/api/images/78be6d37-3ed2-4e3c-8952-efe88c192576"
  /// Returns null if beforePhoto is null or empty
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

  @override
  Widget build(BuildContext context) {
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
                  Expanded(
                    child: const Text(
                      'Complaints',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.sort,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const CustomerProfilePage(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Icon(
                        Icons.search,
                        color: Color(0xFF136AF6),
                        size: 22,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search by keyword or address',
                          hintStyle: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
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
              ),
            ),

       
            // Complaints List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF136AF6)),
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
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage!,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadComplaints,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF136AF6),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _complaints.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inbox_outlined,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No complaints found',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadComplaints,
                              color: const Color(0xFF136AF6),
                              child: ListView.builder(
                                padding: const EdgeInsets.all(20),
                                itemCount: _complaints.length,
                                itemBuilder: (context, index) {
                                  final complaint = _complaints[index];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => ComplaintDetailPage(
                                            complaintId: complaint.id,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
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
                                                Row(
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.transparent,
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Material(
                                                        color: Colors.transparent,
                                                        child: InkWell(
                                                          onTap: complaint.isFixed ? null : () {},
                                                          borderRadius: BorderRadius.circular(8),
                                                          child: Padding(
                                                            padding: const EdgeInsets.all(8),
                                                            child: Icon(
                                                              Icons.thumb_up,
                                                              color: complaint.isFixed 
                                                                  ? const Color(0xFF64748B).withOpacity(0.5)
                                                                  : const Color(0xFF64748B),
                                                              size: 20,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.transparent,
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Material(
                                                        color: Colors.transparent,
                                                        child: InkWell(
                                                          onTap: complaint.isFixed ? null : () {},
                                                          borderRadius: BorderRadius.circular(8),
                                                          child: Padding(
                                                            padding: const EdgeInsets.all(8),
                                                            child: Icon(
                                                              Icons.share,
                                                              color: complaint.isFixed 
                                                                  ? const Color(0xFF64748B).withOpacity(0.5)
                                                                  : const Color(0xFF64748B),
                                                              size: 20,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.transparent,
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Material(
                                                        color: Colors.transparent,
                                                        child: InkWell(
                                                          onTap: complaint.isFixed ? null : () {},
                                                          borderRadius: BorderRadius.circular(8),
                                                          child: Padding(
                                                            padding: const EdgeInsets.all(8),
                                                            child: Icon(
                                                              Icons.more_vert,
                                                              color: complaint.isFixed 
                                                                  ? const Color(0xFF64748B).withOpacity(0.5)
                                                                  : const Color(0xFF64748B),
                                                              size: 20,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF136AF6), Color(0xFF0D5AE0)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF136AF6).withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const NewComplaintPage(),
              ),
            );
            // Refresh list if complaint was created successfully
            if (result == true) {
              _loadComplaints();
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
