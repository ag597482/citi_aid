import 'package:flutter/material.dart';
import 'new_complaint.dart';
import 'customer_profile.dart';
import 'complaint_detail.dart';

class Complaint {
  final String id;
  final String title;
  final String description;
  final String category;
  final String priority;
  final String status;
  final String distance;
  final String timePosted;
  final String imageUrl;
  final int likes;
  final bool isFixed;

  Complaint({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.distance,
    required this.timePosted,
    required this.imageUrl,
    required this.likes,
    this.isFixed = false,
  });
}

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  String _selectedView = 'List';
  final TextEditingController _searchController = TextEditingController();

  final List<Complaint> _complaints = [
    Complaint(
      id: '1',
      title: 'Large Pothole on Main St',
      description: 'Deep pothole causing traffic issues near the intersection with Oak Ave.',
      category: 'Roads',
      priority: 'high',
      status: 'In-progress',
      distance: '0.2 miles away',
      timePosted: 'Posted 3h ago',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuB9PEdCJzb0MRSbrQVeKd0F3pQ061-N84PrTKkEQZy9MQ8QX28-6iPhXZFMnL1AXPwvxLmiO9U06lJswXjU-9P1ualwhQTJnXnxlh6OePEDH--jPLUixWE7R_Ghf2r4ald5es8uxdDO3keyb5EtkCtPQun_t8_lNU57dBwUgJPtL29LS7ZE_NjBOAgLM8glJFbDvSrfsQuCJvKU6wssO77u3Lk4Gl4bV8rHTOdScPaPyf01PeoOlaNIF_MzcyAQSFz9UFbDjcW30w',
      likes: 12,
    ),
    Complaint(
      id: '2',
      title: 'Broken Streetlight',
      description: 'The streetlight at the corner of 5th and Pine has been out for a week.',
      category: 'Utilities',
      priority: 'medium',
      status: 'Raised',
      distance: '0.5 miles away',
      timePosted: 'Posted 1d ago',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuA-aho9hbwkf3aG2Fpbh_pr1pC_RdZa1vCVl7hW5um1Bq-TvOjdrue7KrXcUJv96GT--1LxtCc2q7CNChD4KbYlPZ-_jp9N8whLehEvSXR_k5dVUSYbNcDnWWwF2ic40hCMcZzYDLa3DTAt0PJ6xvJrhl-eqGvTIwBWUQEWoxVfh3NlU1h1r1LCRofLVr1T_yeR1I9j_jwcqh5u1iyuzpBcHWqXQZlza_gyIzlEmPeqzrLt6CNcHsCPNYWmm9MTRXpbhynp83_YAQ',
      likes: 5,
    ),
    Complaint(
      id: '3',
      title: 'Overflowing Dumpster',
      description: 'The public dumpster behind the library hasn\'t been emptied and is attracting pests.',
      category: 'Waste',
      priority: 'medium',
      status: 'Agent Assigned',
      distance: '1.2 miles away',
      timePosted: 'Posted 2d ago',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAx4zhBEN__k9BRMdzjinuNUdcayVH2vQ8kLEO1gZUazd8wDUoxAqxJlKCmuMKPjiEsW4-IvllzqCkj_iI5dQilhg7H5LMme-HGpP0LaMHtWE-r43DOq6XE8xgkOo-PtHOvuSGIobvk57buYvNkrN8WdcgDO1GzYeh89hMnqsasdFAe3RX-BNO3oeqFrNQvBLMGXqCkg2pECyKcGVpET7Hiorobe_NhieUuwlFN3cqub2g1j01FXXOv3g4MzNOloxYJ87KhJtCt7Q',
      likes: 21,
    ),
    Complaint(
      id: '4',
      title: 'Graffiti on Park Wall',
      description: 'Graffiti on the main wall of Central Park.',
      category: 'Graffiti',
      priority: 'low',
      status: 'Fixed',
      distance: '2.5 miles away',
      timePosted: 'Posted 5d ago',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDaA8GaIYomeOUleRX6RbGK3jv_iHMGg_WaoUPkSvPcxqUnhHEtrGk0Cz0PVTK3YIkUjPbmGiZd5pBNBxjMPBxjpwKAAhhHx8L8vSAEITPYM125kLMEL6bx_-_XwL4FXArSRs0nWwcwl6hxxvmbG2OESn-QuZtLPA14rZRGxh2jT34rh23NtA-ilkWZBVks21GoObOfwxmFRBaPYDl_0zjT2SCu7Ab9IMYST2wA7Qv9EGxl3nPnRvYwjJ5QsDtW7nfy5sayswRPjg',
      likes: 3,
      isFixed: true,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'roads':
        return const Color(0xFFFF9500); // warning
      case 'utilities':
        return const Color(0xFF136AF6); // primary
      case 'waste':
        return const Color(0xFFFF3B30); // danger
      default:
        return const Color(0xFF64748B); // gray
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'in-progress':
        return const Color(0xFFFF9500); // warning
      case 'raised':
        return const Color(0xFF64748B); // gray
      case 'agent assigned':
        return const Color(0xFF136AF6); // primary
      case 'fixed':
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
            // Top App Bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Complaints',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.location_on,
                            color: Color(0xFF64748B),
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.sort,
                            color: Color(0xFF64748B),
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
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
                            color: Color(0xFF64748B),
                            size: 20,
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Icon(
                        Icons.search,
                        color: Color(0xFF64748B),
                        size: 20,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search by keyword or address',
                          hintStyle: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // View Toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedView = 'List'),
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: _selectedView == 'List' 
                                ? const Color(0xFF136AF6) 
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'List',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: _selectedView == 'List' 
                                    ? Colors.white 
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedView = 'Map'),
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: _selectedView == 'Map' 
                                ? const Color(0xFF136AF6) 
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'Map',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: _selectedView == 'Map' 
                                    ? Colors.white 
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Complaints List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
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
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
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
                                            color: _getCategoryColor(complaint.category).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(
                                              color: _getCategoryColor(complaint.category).withOpacity(0.2),
                                            ),
                                          ),
                                          child: Text(
                                            complaint.category,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: _getCategoryColor(complaint.category),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          _getPriorityIcon(complaint.priority),
                                          color: complaint.priority == 'high' 
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
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          complaint.distance,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Text(
                                          '·',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          complaint.timePosted,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(complaint.imageUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
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
                                  complaint.status,
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
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.thumb_up,
                                                color: complaint.isFixed 
                                                    ? const Color(0xFF64748B).withOpacity(0.5)
                                                    : const Color(0xFF64748B),
                                                size: 20,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${complaint.likes}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: complaint.isFixed 
                                                      ? const Color(0xFF64748B).withOpacity(0.5)
                                                      : const Color(0xFF64748B),
                                                ),
                                              ),
                                            ],
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const NewComplaintPage(),
            ),
          );
        },
        backgroundColor: const Color(0xFF136AF6),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
