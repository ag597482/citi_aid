import 'package:flutter/material.dart';
import 'active_complaints.dart';
import 'add_new_agent.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  String _selectedTimeFilter = 'Today';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F7F8),
                border: Border(
                  bottom: BorderSide(color: Color(0xFF8E8E93), width: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111318),
                      ),
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      onPressed: () {
                        // Handle notifications
                      },
                      icon: const Icon(
                        Icons.notifications,
                        color: Color(0xFF111318),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Icon(
                        Icons.search,
                        color: Color(0xFF6B7280),
                        size: 20,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search ID, address, agent...',
                          hintStyle: TextStyle(
                            color: Color(0xFF6B7280),
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
                          color: Color(0xFF111318),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Filter Chips
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildFilterChip('Today', _selectedTimeFilter == 'Today'),
                  const SizedBox(width: 12),
                  _buildFilterChip('7d', _selectedTimeFilter == '7d'),
                  const SizedBox(width: 12),
                  _buildFilterChip('30d', _selectedTimeFilter == '30d'),
                  const SizedBox(width: 12),
                  _buildFilterChip('Open', _selectedTimeFilter == 'Open'),
                  const SizedBox(width: 12),
                  _buildFilterChip('High severity', _selectedTimeFilter == 'High severity'),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Actions
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111318),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.2,
                      children: [
                        _buildQuickActionCard(
                          icon: Icons.person_add,
                          title: 'Assign Agent',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ActiveComplaintsPage(),
                              ),
                            );
                          },
                        ),
                        _buildQuickActionCard(
                          icon: Icons.group_add,
                          title: 'Add New Agent',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const AddNewAgentPage(),
                              ),
                            );
                          },
                        ),
                        _buildQuickActionCard(
                          icon: Icons.list_alt,
                          title: 'Monitor Complaints',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ActiveComplaintsPage(),
                              ),
                            );
                          },
                        ),
                        _buildQuickActionCard(
                          icon: Icons.people,
                          title: 'Monitor Agents',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Monitor Agents')),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Snapshot
                    const Text(
                      'Snapshot',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111318),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.5,
                      children: [
                        _buildStatCard('Open', '12', Colors.red),
                        _buildStatCard('Assigned', '28', Colors.orange),
                        _buildStatCard('Fixed (7d)', '56', Colors.green),
                        _buildStatCard('Pending Approvals', '4', const Color(0xFF111318)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildStatCard('Avg. SLA', '2.5h', const Color(0xFF111318)),

                    const SizedBox(height: 24),

                    // Recent Activity
                    const Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111318),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: [
                        _buildActivityItem(
                          icon: Icons.add_task,
                          color: Colors.green,
                          title: 'New complaint',
                          highlightedText: '#12345',
                          subtitle: '2m ago',
                        ),
                        const SizedBox(height: 16),
                        _buildActivityItem(
                          icon: Icons.assignment_ind,
                          color: Colors.blue,
                          title: 'Complaint',
                          highlightedText: '#12321',
                          subtitle: '5m ago',
                          additionalText: 'assigned to John Doe.',
                        ),
                        const SizedBox(height: 16),
                        _buildActivityItem(
                          icon: Icons.delete,
                          color: Colors.red,
                          title: 'Complaint',
                          highlightedText: '#12300',
                          subtitle: '1h ago',
                          additionalText: 'discarded by Jane Smith.',
                        ),
                        const SizedBox(height: 16),
                        _buildActivityItem(
                          icon: Icons.assignment_ind,
                          color: Colors.blue,
                          title: 'Complaint',
                          highlightedText: '#12315',
                          subtitle: '2h ago',
                          additionalText: 'assigned to Alex Ray.',
                        ),
                        const SizedBox(height: 16),
                        _buildActivityItem(
                          icon: Icons.add_task,
                          color: Colors.green,
                          title: 'New complaint',
                          highlightedText: '#12344',
                          subtitle: '3h ago',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedTimeFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF136AF6) : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF111318),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF136AF6).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: const Color(0xFF136AF6),
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111318),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color color,
    required String title,
    required String highlightedText,
    required String subtitle,
    String? additionalText,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF111318),
              ),
              children: [
                TextSpan(text: title),
                const TextSpan(text: ' '),
                TextSpan(
                  text: highlightedText,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF136AF6),
                  ),
                ),
                if (additionalText != null) ...[
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: additionalText,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111318),
                    ),
                  ),
                ],
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
