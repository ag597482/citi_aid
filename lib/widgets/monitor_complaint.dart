import 'package:flutter/material.dart';
import 'complaint_detail.dart';
import '../services/complaint_service.dart';

class MonitorComplaintPage extends StatefulWidget {
  const MonitorComplaintPage({super.key});

  @override
  State<MonitorComplaintPage> createState() => _MonitorComplaintPageState();
}

class _MonitorComplaintPageState extends State<MonitorComplaintPage> {
  final ComplaintService _complaintService = ComplaintService();
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedStatus;
  
  // Status data - matching backend enum: RAISED, AGENT_ASSIGNED, IN_PROGRESS, FIXED, DISCARDED
  final List<String> _statuses = ['RAISED', 'AGENT_ASSIGNED', 'IN_PROGRESS', 'FIXED', 'DISCARDED'];
  Map<String, int> _statusCounts = {};
  Map<String, List<Map<String, dynamic>>> _complaintsByStatus = {};

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  /// Load all complaints and group by status
  Future<void> _loadComplaints() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _complaintService.getAllComplaints();

      if (response.success && response.data != null) {
        final complaintsList = response.data as List;
        final allComplaints = complaintsList
            .map((json) => _mapComplaintFromApi(json as Map<String, dynamic>))
            .toList();

        // Group complaints by status
        final statusCounts = <String, int>{};
        final complaintsByStatus = <String, List<Map<String, dynamic>>>{};

        for (final status in _statuses) {
          statusCounts[status] = 0;
          complaintsByStatus[status] = [];
        }

        for (final complaint in allComplaints) {
          final status = complaint['statusKey'] as String;
          if (statusCounts.containsKey(status)) {
            statusCounts[status] = (statusCounts[status] ?? 0) + 1;
            complaintsByStatus[status]!.add(complaint);
          }
        }

        setState(() {
          _statusCounts = statusCounts;
          _complaintsByStatus = complaintsByStatus;
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
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        formattedDate = '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
      } catch (e) {
        formattedDate = createdAt;
      }
    }

    // Normalize status key - use as-is from backend
    String statusKey = status.toUpperCase();
    // Handle any variations if needed
    if (statusKey == 'IN-PROGRESS') {
      statusKey = 'IN_PROGRESS';
    }

    return {
      'id': json['id'] as String,
      'title': json['title'] as String? ?? 'Untitled',
      'category': _getCategoryDisplayName(department),
      'severity': _getSeverityDisplayName(severity),
      'severityColor': _getSeverityColor(severity),
      'location': json['location'] as String? ?? 'Unknown location',
      'status': _getStatusDisplayName(status),
      'statusColor': _getStatusColor(status),
      'statusKey': statusKey,
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
      case 'AGENT_ASSIGNED':
        return 'Assigned';
      case 'IN_PROGRESS':
      case 'IN-PROGRESS':
        return 'In Progress';
      case 'FIXED':
        return 'Fixed';
      case 'DISCARDED':
        return 'Discarded';
      default:
        return status;
    }
  }

  /// Get status color
  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'RAISED':
        return Colors.green;
      case 'AGENT_ASSIGNED':
        return Colors.blue;
      case 'IN_PROGRESS':
      case 'IN-PROGRESS':
        return Colors.orange;
      case 'FIXED':
        return Colors.teal;
      case 'DISCARDED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Get status color for chart
  Color _getStatusChartColor(String status) {
    switch (status) {
      case 'RAISED':
        return Colors.green;
      case 'AGENT_ASSIGNED':
        return Colors.blue;
      case 'IN_PROGRESS':
        return Colors.orange;
      case 'FIXED':
        return Colors.teal;
      case 'DISCARDED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Get status display name for chart
  String _getStatusChartLabel(String status) {
    switch (status) {
      case 'RAISED':
        return 'New';
      case 'AGENT_ASSIGNED':
        return 'Assigned';
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'FIXED':
        return 'Fixed';
      case 'DISCARDED':
        return 'Discarded';
      default:
        return status;
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
                      'Monitor Complaints',
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
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: _loadComplaints,
                      icon: const Icon(Icons.refresh, color: Colors.white, size: 24),
                      tooltip: 'Refresh',
                    ),
                  ),
                ],
              ),
            ),

            // Content
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
                      : Column(
                          children: [
                            // Bar Chart
                            Container(
                              margin: const EdgeInsets.all(20),
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
                                  const Text(
                                    'Complaints by Status',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF111318),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    height: 250,
                                    child: _buildCustomBarChart(),
                                  ),
                                ],
                              ),
                            ),

                            // Selected Status Header
                            if (_selectedStatus != null)
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: _getStatusChartColor(_selectedStatus!).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _getStatusChartColor(_selectedStatus!),
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.filter_list,
                                      color: _getStatusChartColor(_selectedStatus!),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${_getStatusChartLabel(_selectedStatus!)} Complaints (${_statusCounts[_selectedStatus!] ?? 0})',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: _getStatusChartColor(_selectedStatus!),
                                      ),
                                    ),
                                    const Spacer(),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _selectedStatus = null;
                                        });
                                      },
                                      child: const Text('Clear'),
                                    ),
                                  ],
                                ),
                              ),

                            // Complaints List
                            Expanded(
                              child: _selectedStatus == null
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.bar_chart,
                                            size: 64,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Select a status bar to view complaints',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : _buildComplaintsList(),
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build custom bar chart
  Widget _buildCustomBarChart() {
    final maxCount = _statusCounts.values.isEmpty
        ? 1
        : _statusCounts.values.reduce((a, b) => a > b ? a : b);
    final maxY = maxCount == 0 ? 10 : (maxCount * 1.2).ceil();
    final gridLines = 5;

    return Padding(
      padding: const EdgeInsets.only(left: 50, right: 20, top: 20, bottom: 40),
      child: Column(
        children: [
          // Y-axis labels and bars
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    // Grid lines
                    ...List.generate(gridLines, (index) {
                      return Positioned(
                        left: 0,
                        right: 0,
                        top: (index / gridLines) * constraints.maxHeight,
                        child: Container(
                          height: 1,
                          color: Colors.grey[200],
                        ),
                      );
                    }),
                    // Y-axis labels
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 40,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(gridLines, (index) {
                          final value = (maxY / gridLines) * (gridLines - index);
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          );
                        }),
                      ),
                    ),
                    // Bars
                    Padding(
                      padding: const EdgeInsets.only(left: 50),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: _statuses.map((status) {
                          final count = _statusCounts[status] ?? 0;
                          final isSelected = _selectedStatus == status;
                          final barHeight = maxY > 0 ? (count / maxY) : 0.0;

                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedStatus = status;
                                });
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Tooltip on selection
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: isSelected
                                        ? Container(
                                            key: ValueKey('tooltip-$status'),
                                            margin: const EdgeInsets.only(bottom: 8),
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[800],
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '${_getStatusChartLabel(status)}\n$count',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          )
                                        : const SizedBox.shrink(key: ValueKey('empty')),
                                  ),
                                  // Bar
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Expanded(
                                            child: TweenAnimationBuilder<double>(
                                              tween: Tween<double>(begin: 0.0, end: barHeight),
                                              duration: const Duration(milliseconds: 800),
                                              curve: Curves.easeOutCubic,
                                              builder: (context, animatedHeight, child) {
                                                return FractionallySizedBox(
                                                  heightFactor: animatedHeight,
                                                  child: AnimatedContainer(
                                                    duration: const Duration(milliseconds: 300),
                                                    curve: Curves.easeInOut,
                                                    decoration: BoxDecoration(
                                                      color: _getStatusChartColor(status),
                                                      borderRadius: const BorderRadius.vertical(
                                                        top: Radius.circular(8),
                                                      ),
                                                      border: isSelected
                                                          ? Border.all(
                                                              color: Colors.black,
                                                              width: 2,
                                                            )
                                                          : null,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: _getStatusChartColor(status).withOpacity(
                                                            isSelected ? 0.5 : 0.3,
                                                          ),
                                                          blurRadius: isSelected ? 12 : 8,
                                                          offset: Offset(0, isSelected ? 6 : 4),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // X-axis labels
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 50),
            child: Row(
              children: _statuses.map((status) {
                return Expanded(
                  child: Text(
                    _getStatusChartLabel(status),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _getStatusChartColor(status),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Build complaints list for selected status
  Widget _buildComplaintsList() {
    final complaints = _complaintsByStatus[_selectedStatus!] ?? [];

    if (complaints.isEmpty) {
      return Center(
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
              'No ${_getStatusChartLabel(_selectedStatus!)} complaints found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadComplaints,
      color: const Color(0xFF136AF6),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: complaints.length,
        itemBuilder: (context, index) {
          final complaint = complaints[index];

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

