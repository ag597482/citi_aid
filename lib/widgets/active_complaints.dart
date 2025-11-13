import 'package:flutter/material.dart';
import 'complaint_detail.dart';
import 'assign_agent.dart';

class ActiveComplaintsPage extends StatefulWidget {
  const ActiveComplaintsPage({super.key});

  @override
  State<ActiveComplaintsPage> createState() => _ActiveComplaintsPageState();
}

class _ActiveComplaintsPageState extends State<ActiveComplaintsPage> {
  final Set<int> _selectedComplaints = {};

  final List<Map<String, dynamic>> _complaints = [
    {
      'id': 12345,
      'title': 'Broken Streetlight',
      'category': 'Streetlight',
      'severity': 'Medium',
      'severityColor': Colors.orange,
      'location': '123 Main St',
      'status': 'New',
      'statusColor': Colors.green,
      'date': 'Oct 27, 2023',
      'selected': false,
    },
    {
      'id': 12346,
      'title': 'Pothole on Elm Street',
      'category': 'Pothole',
      'severity': 'High',
      'severityColor': Colors.red,
      'location': '456 Elm St',
      'status': 'In Progress',
      'statusColor': Colors.orange,
      'date': 'Oct 26, 2023',
      'selected': false,
    },
    {
      'id': 12347,
      'title': 'Overflowing Dustbin',
      'category': 'Waste Mgmt',
      'severity': 'Medium',
      'severityColor': Colors.orange,
      'location': '789 Oak Ave',
      'status': 'New',
      'statusColor': Colors.green,
      'date': 'Oct 25, 2023',
      'selected': true,
    },
    {
      'id': 12348,
      'title': 'Illegal Parking',
      'category': 'Parking',
      'severity': 'Low',
      'severityColor': Colors.yellow,
      'status': 'Resolved',
      'statusColor': Colors.grey,
      'location': '101 Pine Rd',
      'date': 'Oct 24, 2023',
      'selected': false,
    },
  ];

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedComplaints.contains(id)) {
        _selectedComplaints.remove(id);
      } else {
        _selectedComplaints.add(id);
      }
    });
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
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _complaints.length,
                itemBuilder: (context, index) {
                  final complaint = _complaints[index];
                  final isSelected = _selectedComplaints.contains(complaint['id'] as int);

                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ComplaintDetailPage(
                            complaintId: complaint['id'] as int,
                            isAdminView: true,
                          ),
                        ),
                      );
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: isSelected,
                            onChanged: (value) {
                              _toggleSelection(complaint['id'] as int);
                            },
                            activeColor: const Color(0xFF136AF6),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
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
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => AssignAgentPage(
                                              complaintId: complaint['id'] as int,
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'Assign',
                                        style: TextStyle(
                                          color: Color(0xFF136AF6),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // View complaint detail
                                      },
                                      child: const Text(
                                        'View',
                                        style: TextStyle(
                                          color: Color(0xFF5F708C),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // Discard complaint
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Discard Complaint'),
                                            content: Text('Are you sure you want to discard complaint #${complaint['id']}?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('Complaint discarded')),
                                                  );
                                                },
                                                child: const Text(
                                                  'Discard',
                                                  style: TextStyle(color: Colors.red),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'Discard',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
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
                    ),
                  );
                },
              ),
            ),

            // Bottom bar
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
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: _selectedComplaints.isEmpty
                          ? null
                          : const LinearGradient(
                              colors: [Color(0xFF136AF6), Color(0xFF0D5AE0)],
                            ),
                      color: _selectedComplaints.isEmpty
                          ? const Color(0xFFE2E8F0)
                          : null,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _selectedComplaints.isEmpty
                          ? null
                          : [
                              BoxShadow(
                                color: const Color(0xFF136AF6).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                    ),
                    child: ElevatedButton(
                      onPressed: _selectedComplaints.isEmpty ? null : () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Bulk Assign (${_selectedComplaints.length} selected)',
                        style: TextStyle(
                          color: _selectedComplaints.isEmpty
                              ? const Color(0xFF64748B)
                              : Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Previous',
                          style: TextStyle(color: Color(0xFF136AF6)),
                        ),
                      ),
                      const Text(
                        'Page 1 of 10',
                        style: TextStyle(color: Color(0xFF5F708C)),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Next',
                          style: TextStyle(color: Color(0xFF136AF6)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Streetlight':
        return Colors.blue;
      case 'Pothole':
        return Colors.yellow;
      case 'Waste Mgmt':
        return Colors.purple;
      case 'Parking':
        return Colors.red;
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

