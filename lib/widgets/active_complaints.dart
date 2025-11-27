import 'package:flutter/material.dart';
import 'complaint_detail.dart';
import '../services/complaint_service.dart';

class ActiveComplaintsPage extends StatefulWidget {
  const ActiveComplaintsPage({super.key});

  @override
  State<ActiveComplaintsPage> createState() => _ActiveComplaintsPageState();
}

class _ActiveComplaintsPageState extends State<ActiveComplaintsPage> {
  final ComplaintService _complaintService = ComplaintService();
  List<Map<String, dynamic>> _complaints = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  /// Load complaints from API (only RAISED status)
  Future<void> _loadComplaints() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _complaintService.getComplaintsByStatus('RAISED');

      if (response.success && response.data != null) {
        final complaintsList = response.data as List;
        setState(() {
          _complaints = complaintsList
              .map((json) => _mapComplaintFromApi(json as Map<String, dynamic>))
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

  /// Map API complaint data to display format
  Map<String, dynamic> _mapComplaintFromApi(Map<String, dynamic> json) {
    final department = json['department'] as String? ?? '';
    final severity = json['severity'] as String? ?? '';
    final status = json['status'] as String? ?? '';
    final createdAt = json['createdAt'] as String?;

    String formattedDate = 'N/A';
    if (createdAt != null) {
      try {
        final dateTime = DateTime.parse(createdAt);
        // Format date manually to avoid intl dependency issues
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        formattedDate = '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
      } catch (e) {
        formattedDate = createdAt;
      }
    }

    return {
      'id': json['id'] as String, // Keep as String (MongoDB ObjectId)
      'title': json['title'] as String? ?? 'Untitled',
      'category': _getCategoryDisplayName(department),
      'severity': _getSeverityDisplayName(severity),
      'severityColor': _getSeverityColor(severity),
      'location': json['location'] as String? ?? 'Unknown location',
      'status': _getStatusDisplayName(status),
      'statusColor': _getStatusColor(status),
      'date': formattedDate,
    };
  }

  /// Get category display name from department
  String _getCategoryDisplayName(String department) {
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

  /// Get severity display name
  String _getSeverityDisplayName(String severity) {
    switch (severity.toUpperCase()) {
      case 'HIGH':
        return 'High';
      case 'MEDIUM':
        return 'Medium';
      case 'LOW':
        return 'Low';
      default:
        return severity;
    }
  }

  /// Get severity color
  Color _getSeverityColor(String severity) {
    switch (severity.toUpperCase()) {
      case 'HIGH':
        return Colors.red;
      case 'MEDIUM':
        return Colors.orange;
      case 'LOW':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  /// Get status display name
  String _getStatusDisplayName(String status) {
    switch (status.toUpperCase()) {
      case 'RAISED':
        return 'New';
      case 'ASSIGNED':
        return 'Assigned';
      case 'IN_PROGRESS':
      case 'IN-PROGRESS':
        return 'In Progress';
      case 'COMPLETED':
      case 'FIXED':
        return 'Resolved';
      default:
        return status;
    }
  }

  /// Get status color
  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'RAISED':
        return Colors.green;
      case 'ASSIGNED':
        return Colors.blue;
      case 'IN_PROGRESS':
      case 'IN-PROGRESS':
        return Colors.orange;
      case 'COMPLETED':
      case 'FIXED':
        return Colors.grey;
      default:
        return Colors.grey;
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
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Complaints',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Filter',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
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
                      final complaintId = complaint['id'];
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ComplaintDetailPage(
                            complaintId: complaintId,
                            isAdminView: true,
                          ),
                        ),
                      ).then((result) {
                        // Refresh complaints list when returning from detail page
                        _loadComplaints();
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            complaint['title'] as String,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111318),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              _buildBadge(
                                complaint['category'] as String,
                                _getCategoryColor(complaint['category'] as String),
                              ),
                              _buildSeverityBadge(
                                complaint['severity'] as String,
                                complaint['severityColor'] as Color,
                              ),
                              _buildLocationBadge(complaint['location'] as String),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            children: [
                              _buildStatusBadge(
                                complaint['status'] as String,
                                complaint['statusColor'] as Color,
                              ),
                              Text(
                                'ID: ${complaint['id']}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF5F708C),
                                ),
                              ),
                              Text(
                                complaint['date'] as String,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF5F708C),
                                ),
                              ),
                            ],
                          ),
                        ],
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
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'electricity':
        return Colors.blue;
      case 'potholes':
        return Colors.yellow;
      case 'drainage':
        return Colors.cyan;
      case 'garbage':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildBadge(String text, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: backgroundColor.withOpacity(0.9),
        ),
      ),
    );
  }

  Widget _buildSeverityBadge(String severity, Color color) {
    IconData icon = Icons.flag;
    if (severity == 'High') icon = Icons.error;
    else if (severity == 'Medium') icon = Icons.priority_high;
    else if (severity == 'Low') icon = Icons.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            severity,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationBadge(String location) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.location_on, size: 16, color: Color(0xFF5F708C)),
        const SizedBox(width: 4),
        Text(
          location,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF5F708C),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

