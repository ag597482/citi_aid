import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/complaint_service.dart';
import '../services/auth_service.dart';
import '../api/api_config.dart';
import 'edit_complaint.dart';
import 'feed_page.dart';
import 'assign_agent.dart';

class ComplaintDetailPage extends StatefulWidget {
  final dynamic complaintId;
  final bool isAdminView;
  
  const ComplaintDetailPage({
    super.key,
    required this.complaintId,
    this.isAdminView = false,
  });

  @override
  State<ComplaintDetailPage> createState() => _ComplaintDetailPageState();
}

class _ComplaintDetailPageState extends State<ComplaintDetailPage> {
  final ComplaintService _complaintService = ComplaintService();
  final AuthService _authService = AuthService();
  
  Map<String, dynamic>? _complaint;
  bool _isLoading = true;
  String? _error;
  String? _currentUserId;
  String? _baseUrl;

  @override
  void initState() {
    super.initState();
    _loadComplaint();
    _loadCurrentUser();
    _loadBaseUrl();
  }

  Future<void> _loadBaseUrl() async {
    final url = await ApiConfig.getBaseUrl();
    setState(() {
      _baseUrl = url;
    });
  }

  Future<void> _loadCurrentUser() async {
    final user = await _authService.getStoredUser();
    setState(() {
      _currentUserId = user?.id;
    });
  }

  Future<void> _loadComplaint() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _complaintService.getComplaintById(
        widget.complaintId.toString(),
      );

      if (response.success && response.data != null) {
        setState(() {
          _complaint = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.error ?? 'Failed to load complaint';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading complaint: $e';
        _isLoading = false;
      });
    }
  }

  String _getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    final baseUrl = _baseUrl ?? 'http://localhost:8080';
    return '$baseUrl$imagePath';
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return '';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('MMM d, yyyy, h:mm a').format(dateTime);
    } catch (e) {
      return dateTimeStr;
    }
  }

  bool _isComplaintCreator() {
    if (_complaint == null || _currentUserId == null) return false;
    final customer = _complaint!['customer'] as Map<String, dynamic>?;
    if (customer == null) return false;
    return customer['id'] == _currentUserId;
  }

  bool _hasAgent() {
    return _complaint != null && _complaint!['agent'] != null;
  }

  bool _isDiscarded() {
    if (_complaint == null) return false;
    final status = _complaint!['status'] as String? ?? '';
    return status.toUpperCase() == 'DISCARDED';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header Bar
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
                      'Complaint Details',
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

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _error!,
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadComplaint,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _complaint == null
                          ? const Center(child: Text('No complaint data'))
                          : SingleChildScrollView(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Content Header
                                  Text(
                                    _complaint!['title'] ?? 'Untitled',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1C1C1E),
                                      letterSpacing: -0.015,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        height: 28,
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFF9500).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Center(
                                          child: Text(
                                            _complaint!['department'] ?? 'Unknown',
                                            style: const TextStyle(
                                              color: Color(0xFFFF9500),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Row(
                                        children: [
                                          Container(
                                            width: 64,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: _getSeverityColor(_complaint!['severity']),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${_complaint!['severity'] ?? 'Unknown'} Severity',
                                            style: TextStyle(
                                              color: _getSeverityColor(_complaint!['severity']),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 24),

                                  // Media Carousel
                                  if (_complaint!['beforePhoto'] != null)
                                    SizedBox(
                                      height: 200,
                                      child: ListView(
                                        scrollDirection: Axis.horizontal,
                                        children: [
                                          Container(
                                            width: 280,
                                            margin: const EdgeInsets.only(right: 12),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                  _getImageUrl(_complaint!['beforePhoto']),
                                                ),
                                                fit: BoxFit.cover,
                                                onError: (exception, stackTrace) {
                                                  // Handle image load error
                                                },
                                              ),
                                            ),
                                          ),
                                          if (_complaint!['afterPhoto'] != null)
                                            Container(
                                              width: 280,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(8),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                    _getImageUrl(_complaint!['afterPhoto']),
                                                  ),
                                                  fit: BoxFit.cover,
                                                  onError: (exception, stackTrace) {
                                                    // Handle image load error
                                                  },
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),

                                  const SizedBox(height: 24),

                                  // Information Section
                                  Column(
                                    children: [
                                      // Description
                                      _buildInfoSection(
                                        icon: Icons.description,
                                        title: 'Description',
                                        content: _complaint!['description'] ?? 'No description',
                                      ),

                                      const SizedBox(height: 16),

                                      // Location
                                      _buildInfoSection(
                                        icon: Icons.location_on,
                                        title: 'Location',
                                        content: _complaint!['location'] ?? 'No location',
                                      ),

                                      const SizedBox(height: 16),

                                      // Reporter
                                      _buildInfoSection(
                                        icon: Icons.person,
                                        title: 'Reporter',
                                        content: _getReporterInfo(),
                                      ),

                                      const SizedBox(height: 16),

                                      // Assigned Agent or Select Agent button
                                      if (_hasAgent()) 
                                        _buildAgentSection()
                                      else if (widget.isAdminView && !_isDiscarded())
                                        _buildSelectAgentSection(),

                                      // Admin actions (Discard button)
                                      if (widget.isAdminView) ...[
                                        const SizedBox(height: 16),
                                        _buildAdminActionsSection(),
                                      ],
                                    ],
                                  ),

                                  const SizedBox(height: 24),

                                  // Status Timeline
                                  _buildStatusTimeline(),

                                  const SizedBox(height: 24),

                                  // CTA Bar
                                  if (_isComplaintCreator())
                                    _buildCTABar(),
                                ],
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(String? severity) {
    switch (severity?.toUpperCase()) {
      case 'HIGH':
        return const Color(0xFFFF3B30);
      case 'MEDIUM':
        return const Color(0xFFFF9500);
      case 'LOW':
        return const Color(0xFF34C759);
      default:
        return const Color(0xFF8E8E93);
    }
  }

  String _getReporterInfo() {
    if (_complaint == null) return 'Unknown';
    final customer = _complaint!['customer'] as Map<String, dynamic>?;
    if (customer == null) return 'Unknown';
    final name = customer['name'] as String? ?? 'Unknown';
    final createdAt = _complaint!['createdAt'] as String?;
    if (createdAt != null) {
      final dateTime = _formatDateTime(createdAt);
      return 'Reported on $dateTime by $name';
    }
    return 'Reported by $name';
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7F8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF8E8E93),
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8E8E93),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildAgentSection() {
    if (_complaint == null || !_hasAgent()) return const SizedBox.shrink();
    
    final agent = _complaint!['agent'];
    String agentName = 'Unknown Agent';
    
    if (agent is Map<String, dynamic>) {
      agentName = agent['name'] as String? ?? 'Unknown Agent';
    } else if (agent is String) {
      agentName = agent;
    }
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7F8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.assignment_ind,
            color: Color(0xFF8E8E93),
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Assigned Agent',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Assigned to $agentName',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8E8E93),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Contacting agent...'),
                        backgroundColor: Color(0xFF007AFF),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5F7F8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Contact Agent',
                    style: TextStyle(
                      color: Color(0xFF1C1C1E),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectAgentSection() {
    if (_complaint == null) return const SizedBox.shrink();
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7F8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.person_add,
            color: Color(0xFF8E8E93),
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Assign Agent',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'No agent assigned yet',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8E8E93),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    final complaintId = _complaint!['id'];
                    String complaintIdString;
                    
                    if (complaintId is String) {
                      complaintIdString = complaintId;
                    } else {
                      complaintIdString = complaintId.toString();
                    }
                    
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AssignAgentPage(
                          complaintId: complaintIdString,
                        ),
                      ),
                    ).then((result) {
                      // Reload complaint if agent was assigned
                      if (result == true) {
                        _loadComplaint();
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF136AF6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Select Agent',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdminActionsSection() {
    if (_complaint == null) return const SizedBox.shrink();
    
    // Don't show discard button if complaint is already discarded
    if (_isDiscarded()) {
      return const SizedBox.shrink();
    }
    
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 40,
            child: ElevatedButton.icon(
              onPressed: () {
                _discardComplaint();
              },
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text(
                'Discard',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.1),
                foregroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _discardComplaint() async {
    if (_complaint == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Discard Complaint',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to discard this complaint? This action will mark it as discarded.',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF1E293B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Discard',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final complaintId = _complaint!['id'];
    String complaintIdString;
    
    if (complaintId is String) {
      complaintIdString = complaintId;
    } else {
      complaintIdString = complaintId.toString();
    }

    try {
      final response = await _complaintService.discardComplaint(complaintIdString);

      if (response.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Complaint discarded successfully'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate back to complaints list
          Navigator.of(context).pop(true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.error ?? 'Failed to discard complaint'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
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

  Widget _buildStatusTimeline() {
    if (_complaint == null) return const SizedBox.shrink();
    
    final List<Map<String, String>> timelineItems = [];
    
    // Add Completed status if exists
    if (_complaint!['completedAt'] != null) {
      timelineItems.add({
        'title': 'Completed',
        'date': _formatDateTime(_complaint!['completedAt']),
      });
    }
    
    // Add Assigned status if exists
    if (_complaint!['assignedAt'] != null) {
      timelineItems.add({
        'title': 'Agent Assigned',
        'date': _formatDateTime(_complaint!['assignedAt']),
      });
    }
    
    // Add Created status (always exists)
    timelineItems.add({
      'title': 'Submitted',
      'date': _formatDateTime(_complaint!['createdAt']),
    });
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status History',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1C1C1E),
          ),
        ),
        const SizedBox(height: 16),
        if (timelineItems.isEmpty)
          const Text(
            'No status history available',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF8E8E93),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.only(left: 32),
            child: Column(
              children: timelineItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Column(
                  children: [
                    _buildTimelineItem(
                      title: item['title']!,
                      date: item['date']!,
                    ),
                    if (index < timelineItems.length - 1) const SizedBox(height: 24),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String date,
    String? description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 6),
          decoration: const BoxDecoration(
            color: Color(0xFF007AFF),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8E8E93),
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8E8E93),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCTABar() {
    if (!_isComplaintCreator()) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFF8E8E93), width: 0.2),
          bottom: BorderSide(color: Color(0xFF8E8E93), width: 0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_complaint != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EditComplaintPage(
                          complaintId: _complaint!['id'] as String,
                          complaint: _complaint!,
                        ),
                      ),
                    ).then((updated) {
                      if (updated == true) {
                        _loadComplaint(); // Reload complaint data
                      }
                    });
                  }
                },
                icon: const Icon(Icons.edit, size: 18, color: Color(0xFF136AF6)),
                label: const Text('Edit', style: TextStyle(color: Color(0xFF136AF6))),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Delete Complaint'),
                        content: const Text('Are you sure you want to delete this complaint? This action cannot be undone.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              // Store navigator reference before async operations
                              final navigator = Navigator.of(context, rootNavigator: true);
                              final scaffoldMessenger = ScaffoldMessenger.of(context);
                              
                              // Close the confirmation dialog
                              navigator.pop();
                              
                              if (_complaint != null) {
                                final complaintId = _complaint!['id'] as String;
                                
                                // Show loading indicator using root navigator
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (dialogContext) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                                
                                try {
                                  final response = await _complaintService.deleteComplaint(complaintId);
                                  
                                  // Close loading indicator
                                  if (mounted) {
                                    navigator.pop();
                                  }
                                  
                                  if (mounted) {
                                    if (response.success) {
                                      // Get the success message before navigation
                                      final successMessage = response.data?['message'] as String? ?? 
                                                             'Complaint deleted successfully';
                                      
                                      // Navigate to feed page first
                                      navigator.pushAndRemoveUntil(
                                        MaterialPageRoute(
                                          builder: (newContext) {
                                            // Show success message after navigation completes
                                            WidgetsBinding.instance.addPostFrameCallback((_) {
                                              ScaffoldMessenger.of(newContext).showSnackBar(
                                                SnackBar(
                                                  content: Text(successMessage),
                                                  backgroundColor: Colors.green,
                                                  duration: const Duration(seconds: 2),
                                                ),
                                              );
                                            });
                                            return const FeedPage();
                                          },
                                        ),
                                        (route) => false, // Remove all previous routes
                                      );
                                    } else {
                                      scaffoldMessenger.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            response.error ?? 
                                            response.data?['message'] as String? ?? 
                                            'Failed to delete complaint'
                                          ),
                                          backgroundColor: Colors.red,
                                          duration: const Duration(seconds: 3),
                                        ),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  // Close loading indicator if still open
                                  if (mounted) {
                                    navigator.pop();
                                  }
                                  
                                  if (mounted) {
                                    scaffoldMessenger.showSnackBar(
                                      SnackBar(
                                        content: Text('Error deleting complaint: $e'),
                                        backgroundColor: Colors.red,
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Color(0xFFFF3B30)),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                label: const Text('Delete Complaint', style: TextStyle(color: Colors.red)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
