import 'package:flutter/material.dart';
import 'update_complaint.dart';

class AgentHomePage extends StatefulWidget {
  const AgentHomePage({super.key});

  @override
  State<AgentHomePage> createState() => _AgentHomePageState();
}

class _AgentHomePageState extends State<AgentHomePage> {
  String _selectedTab = 'Active';

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
                  // Search bar
                  Container(
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
                    child: _buildTab('Active', _selectedTab == 'Active'),
                  ),
                  Expanded(
                    child: _buildTab('Past', _selectedTab == 'Past'),
                  ),
                  Expanded(
                    child: _buildTab('Pending', _selectedTab == 'Pending'),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _selectedTab == 'Active'
                  ? _buildComplaintsList()
                  : _buildEmptyState(),
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildComplaintCard(
          id: '12345',
          title: 'Pothole on Main St',
          category: 'Pothole',
          severity: 'High',
          severityColor: Colors.red,
          status: 'Assigned',
          statusColor: Colors.green,
          timeAgo: '2h ago',
          imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAGcAsH-aitYIzNFGwmBzg5UUZMjcBROz6Py2gZeJ5615NJN24lii-vt4cK6Jgz-aOm_PvoqgDuV-x__k-PBXALatkJrvRxwLQq0y_5aYc1iUc3hjX6NdJPLxuie_Mi3nPHyU6Teuzbei5k_xqcLJvm2JoDWjm8T1wr8mAq7WFG_O4ovMYZRuXzl0k8pGnN8XMEwBs1gsjfItTiP0S2FSIsqWjsaRbP369QlGIAJE8_xyJ7Bi_FjRZbBjXGesftq9nwHOuVHrQgHQ',
        ),
        const SizedBox(height: 16),
        _buildComplaintCard(
          id: '67890',
          title: 'Broken Streetlight',
          category: 'Streetlight',
          severity: 'Medium',
          severityColor: Colors.orange,
          status: 'In Progress',
          statusColor: Colors.yellow,
          timeAgo: '5h ago',
          imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAHZEI7xMThrYdJzZ65F8WI13dz1YX7rMDRqSUJpBt8IbRV5SU4lyEF5Nw63HFzIXzCb0KQ411p9-UFTXZ9o1IzoOaadCLuSUSvQaFEbpZ22VKavuRBDeslrrd8dBcIyIobdkKb5I_d8EElqep72m3-Qiw946WYGQP_FylnQRT1Zlce1OoZ8gKLmIhSUaCGWPzUCWVXg8MD8RkGqjm0RsQU7OvgqrSIp6anuxA0x1UZt7xpljTWyfJkbHMKf7Jl9EVp5nAotw0gUQ',
        ),
        const SizedBox(height: 16),
        _buildComplaintCard(
          id: '11223',
          title: 'Graffiti on Wall',
          category: 'Vandalism',
          severity: 'Low',
          severityColor: Colors.green,
          status: 'Assigned',
          statusColor: Colors.green,
          timeAgo: '1d ago',
          imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDRH9TSrko8JXQXI4_iyj-NMIoG-jYGOL7bcK-XjBLbbIsApBPzEvjJJLctV4_n9ZvgcQVgnL-t_0j7EpD41elvsqg5gUbkTfAKGHkljTHZ50gcFZa_fWf1RUnUXT9nMFd98p4ycMtFj0U54JGRqLdAHVGZeGxSZK5cP6i_q0nCNkfWy-dtPomSmL7KRA7Fy0e1tsFRyDwenW1PTP1LFLNNzET0vZLbFoPtHrd-NyvgfHejSEx33wr1VKEUDulGMnE6QynIjK6wKQ',
        ),
      ],
    );
  }

  Widget _buildComplaintCard({
    required String id,
    required String title,
    required String category,
    required String severity,
    required Color severityColor,
    required String status,
    required Color statusColor,
    required String timeAgo,
    required String imageUrl,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => UpdateComplaintPage(complaintId: id),
          ),
        );
      },
      child: Container(
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
            // Card content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      image: DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and status
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'ID: $id - $title',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1C1C1E),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Category and severity
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD0E4FF),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                category,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF007AFF),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    severity == 'High'
                                        ? Icons.priority_high
                                        : severity == 'Medium'
                                            ? Icons.warning
                                            : Icons.flag,
                                    size: 16,
                                    color: severityColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$severity Severity',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: severityColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          timeAgo,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8A8A8E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Actions
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                border: const Border(
                  top: BorderSide(
                    color: Color(0xFFD1D1D6),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.navigation,
                      label: 'Navigate',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 48,
                    color: const Color(0xFFD1D1D6),
                  ),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.call,
                      label: 'Call',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 48,
                    color: const Color(0xFFD1D1D6),
                  ),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.update,
                      label: 'Update',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
  }) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF136AF6),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF136AF6),
            ),
          ),
        ],
      ),
    );
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
            'Check the Pending tab or pull to refresh.',
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

