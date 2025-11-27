import 'package:flutter/material.dart';
import 'active_complaints.dart';
import 'add_new_agent.dart';
import 'agents_summary.dart';
import 'monitor_complaint.dart';
import '../services/complaint_service.dart';
import '../services/auth_service.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final ComplaintService _complaintService = ComplaintService();
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  // Complaints summary data
  Map<String, int> _complaintsSummary = {
    'openComplaints': 0,
    'assignedComplaints': 0,
    'inProgressComplaints': 0,
    'fixedComplaints': 0,
  };

  @override
  void initState() {
    super.initState();
    _fetchComplaintsSummary();
  }

  Future<void> _fetchComplaintsSummary() async {
    setState(() {
      _isLoading = true;
    });

    final response = await _complaintService.getComplaintsSummary();

    if (response.success && response.data != null) {
      setState(() {
        _complaintsSummary = response.data!;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error ?? 'Failed to load complaints summary'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      body: SafeArea(
        child: Column(
          children: [
            // Header - Fixed at top
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
                  const Expanded(
                    child: Text(
                      'Dashboard',
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
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: const Text(
                                'Logout',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: const Text('Are you sure you want to logout?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    await _authService.logout();
                                    if (mounted) {
                                      Navigator.of(context).pushReplacementNamed('/login');
                                    }
                                  },
                                  child: const Text(
                                    'Logout',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.white,
                        size: 24,
                      ),
                      tooltip: 'Logout',
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenHeight = MediaQuery.of(context).size.height;
                  final isSmallScreen = screenHeight < 750;
                  final isVerySmallScreen = screenHeight < 650;
                  
                  return SingleChildScrollView(
                    padding: EdgeInsets.only(
                      top: isVerySmallScreen ? 8 : (isSmallScreen ? 12 : 20),
                      bottom: isVerySmallScreen ? 8 : (isSmallScreen ? 12 : 20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Complaints Summary
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: isVerySmallScreen ? 16 : 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Complaints Summary',
                                      style: TextStyle(
                                        fontSize: isVerySmallScreen ? 18 : (isSmallScreen ? 20 : 22),
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF111318),
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ),
                                  if (_isLoading)
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF136AF6)),
                                      ),
                                    )
                                  else
                                    IconButton(
                                      icon: const Icon(Icons.refresh, color: Color(0xFF136AF6)),
                                      onPressed: _fetchComplaintsSummary,
                                      tooltip: 'Refresh',
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                ],
                              ),
                              SizedBox(height: isVerySmallScreen ? 8 : (isSmallScreen ? 12 : 16)),
                              _isLoading
                                  ? SizedBox(
                                      height: isVerySmallScreen ? 140 : (isSmallScreen ? 160 : 200),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF136AF6)),
                                        ),
                                      ),
                                    )
                                  : GridView.count(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      crossAxisCount: 2,
                                      mainAxisSpacing: isVerySmallScreen ? 8 : (isSmallScreen ? 12 : 16),
                                      crossAxisSpacing: isVerySmallScreen ? 8 : (isSmallScreen ? 12 : 16),
                                      childAspectRatio: isVerySmallScreen ? 1.6 : (isSmallScreen ? 1.5 : 1.4),
                                      children: [
                                        _buildSummaryCard(
                                          'Open',
                                          _complaintsSummary['openComplaints']!.toString(),
                                          Colors.red,
                                          Icons.assignment_outlined,
                                          isSmallScreen: isSmallScreen,
                                          isVerySmallScreen: isVerySmallScreen,
                                        ),
                                        _buildSummaryCard(
                                          'Assigned',
                                          _complaintsSummary['assignedComplaints']!.toString(),
                                          Colors.orange,
                                          Icons.person_outline,
                                          isSmallScreen: isSmallScreen,
                                          isVerySmallScreen: isVerySmallScreen,
                                        ),
                                        _buildSummaryCard(
                                          'In Progress',
                                          _complaintsSummary['inProgressComplaints']!.toString(),
                                          Colors.blue,
                                          Icons.work_outline,
                                          isSmallScreen: isSmallScreen,
                                          isVerySmallScreen: isVerySmallScreen,
                                        ),
                                        _buildSummaryCard(
                                          'Fixed',
                                          _complaintsSummary['fixedComplaints']!.toString(),
                                          Colors.green,
                                          Icons.check_circle_outline,
                                          isSmallScreen: isSmallScreen,
                                          isVerySmallScreen: isVerySmallScreen,
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                        ),

                        SizedBox(height: isVerySmallScreen ? 12 : (isSmallScreen ? 16 : 24)),

                        // Quick Actions
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: isVerySmallScreen ? 16 : 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Quick Actions',
                                style: TextStyle(
                                  fontSize: isVerySmallScreen ? 18 : (isSmallScreen ? 20 : 22),
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF111318),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(height: isVerySmallScreen ? 8 : (isSmallScreen ? 12 : 16)),
                              GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                mainAxisSpacing: isVerySmallScreen ? 8 : (isSmallScreen ? 12 : 16),
                                crossAxisSpacing: isVerySmallScreen ? 8 : (isSmallScreen ? 12 : 16),
                                childAspectRatio: isVerySmallScreen ? 1.4 : (isSmallScreen ? 1.3 : 1.2),
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
                                    isSmallScreen: isSmallScreen,
                                    isVerySmallScreen: isVerySmallScreen,
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
                                    isSmallScreen: isSmallScreen,
                                    isVerySmallScreen: isVerySmallScreen,
                                  ),
                                  _buildQuickActionCard(
                                    icon: Icons.list_alt,
                                    title: 'Monitor Complaints',
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => const MonitorComplaintPage(),
                                        ),
                                      );
                                    },
                                    isSmallScreen: isSmallScreen,
                                    isVerySmallScreen: isVerySmallScreen,
                                  ),
                                  _buildQuickActionCard(
                                    icon: Icons.people,
                                    title: 'Monitor Agents',
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => const AgentsSummaryPage(),
                                        ),
                                      );
                                    },
                                    isSmallScreen: isSmallScreen,
                                    isVerySmallScreen: isVerySmallScreen,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, Color color, IconData icon, {bool isSmallScreen = false, bool isVerySmallScreen = false}) {
    return Container(
      padding: EdgeInsets.all(isVerySmallScreen ? 12 : (isSmallScreen ? 16 : 20)),
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
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isVerySmallScreen ? 5 : (isSmallScreen ? 6 : 8)),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: isVerySmallScreen ? 16 : (isSmallScreen ? 18 : 20),
                ),
              ),
              const Spacer(),
            ],
          ),
          SizedBox(height: isVerySmallScreen ? 6 : (isSmallScreen ? 8 : 12)),
          Text(
            label,
            style: TextStyle(
              fontSize: isVerySmallScreen ? 11 : (isSmallScreen ? 12 : 13),
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: isVerySmallScreen ? 4 : (isSmallScreen ? 6 : 8)),
          Text(
            value,
            style: TextStyle(
              fontSize: isVerySmallScreen ? 24 : (isSmallScreen ? 28 : 32),
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSmallScreen = false,
    bool isVerySmallScreen = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isVerySmallScreen ? 12 : (isSmallScreen ? 16 : 20)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF136AF6).withOpacity(0.1),
              const Color(0xFF136AF6).withOpacity(0.05),
            ],
          ),
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
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isVerySmallScreen ? 40 : (isSmallScreen ? 48 : 56),
              height: isVerySmallScreen ? 40 : (isSmallScreen ? 48 : 56),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF136AF6), Color(0xFF0D5AE0)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF136AF6).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: isVerySmallScreen ? 20 : (isSmallScreen ? 24 : 28),
              ),
            ),
            SizedBox(height: isVerySmallScreen ? 6 : (isSmallScreen ? 8 : 12)),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isVerySmallScreen ? 12 : (isSmallScreen ? 13 : 15),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
