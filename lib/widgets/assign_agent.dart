import 'package:flutter/material.dart';

class AssignAgentPage extends StatefulWidget {
  final int complaintId;
  
  const AssignAgentPage({
    super.key,
    required this.complaintId,
  });

  @override
  State<AssignAgentPage> createState() => _AssignAgentPageState();
}

class _AssignAgentPageState extends State<AssignAgentPage> {
  String _selectedView = 'Suggested Agents';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _agents = [
    {
      'name': 'Olivia',
      'department': 'Sanitation',
      'active': 5,
      'lastActive': '2h ago',
      'rating': 4.5,
      'avatar': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCJ69VlmOEGTxVtWBGsl9-YHYxGte5FoFXWH3_jVLDX3oa8JOLJPLxoI2siInOFzBtzu9Nv5k7PsY3XOvCLPSPoYcOws3nLykNTqAd2gXXcimWUOm0YfEliUV9ZzUy2IRlVpB3k9Lpr5PVih1X0inF6Arp8wdb7_vKyeWjSPSy4EWCw1Uot0FRzAp9urLP1qx8fq8k4_FcwbjzTPdm_dBG7MDkTpxDLiQWz7T0W4zY6JSOr-RU_WgSwmIje33qxwePL17k9w0ysJg',
      'isSuggested': true,
    },
    {
      'name': 'Liam',
      'department': 'Public Works',
      'active': 2,
      'lastActive': '30m ago',
      'rating': 4.8,
      'avatar': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDoMefKYNYwtWRx3IiHszBtgJgbCg83nH0Q9BzkRPDhkhH-UuJAt4tUZKTePdAVBD-ToUjiur-ZUY-w0N9NaMcl-mHVIp3cjswepeo8DxCC7YeK1VF33-U0kohNEvAfg3ZDX6vVuvWY4AqV6Q3ZcaFzMU8QSaSJTcwESILSRBVkQK-K9jPkir0ykMEzdQlgP_5vvCxDF86fX4wAXB3IQCXL2hSk93LzUT7zxwNnNRPvNwRkGKj7CnIQE-A0u6fBtplGZSeI07zbfA',
      'isSuggested': true,
    },
    {
      'name': 'Noah',
      'department': 'Parks & Rec',
      'active': 1,
      'lastActive': '5m ago',
      'rating': 4.9,
      'avatar': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBERUZYnE8C8Qcg-xdfIRZ-uv_M3AlIOODmbwFmYWZ4oJPi0lQGhBZpjGbkkkwwxzpmm5kXv7lJ-Clw0SNigogMtUxTnWl-xaWb220qWt9w0L-yZL1M9hEXOTc15oH8ge7mEtTBrFRXwCHjkfktxWKQEF1anlXKpr215HDLEgUYtGidRphKMq5bbVxjt1j4XEHtXC4QlpKhAw6t-_xF5dNjq4B6NiM_88wUusGdvyoxccvs2Yo9s00CGrLttGuAGLVwBI25GoRYLA',
      'isSuggested': true,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                      'Assign Agent',
                      textAlign: TextAlign.center,
                      style: TextStyle(
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

            // Search bar
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7F8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
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
                          hintText: 'Search by name, department...',
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

            // View toggle
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7F8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedView = 'Suggested Agents'),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: _selectedView == 'Suggested Agents'
                              ? const LinearGradient(
                                  colors: [Color(0xFF136AF6), Color(0xFF0D5AE0)],
                                )
                              : null,
                          color: _selectedView == 'Suggested Agents' ? null : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: _selectedView == 'Suggested Agents'
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF136AF6).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            'Suggested Agents',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _selectedView == 'Suggested Agents'
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
                      onTap: () => setState(() => _selectedView = 'All Agents'),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: _selectedView == 'All Agents'
                              ? const LinearGradient(
                                  colors: [Color(0xFF136AF6), Color(0xFF0D5AE0)],
                                )
                              : null,
                          color: _selectedView == 'All Agents' ? null : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: _selectedView == 'All Agents'
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF136AF6).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            'All Agents',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _selectedView == 'All Agents'
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

          // Agents list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 16),
              itemCount: _agents.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Top Picks',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111318),
                      ),
                    ),
                  );
                }

                final agent = _agents[index - 1];

                return Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
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
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          image: DecorationImage(
                            image: NetworkImage(agent['avatar'] as String),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              agent['name'] as String,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF111318),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${agent['active'] as int} Active | Last active: ${agent['lastActive'] as String} | ${agent['rating'] as double} ★',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF5F708C),
                              ),
                            ),
                            Text(
                              agent['department'] as String,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF5F708C),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 100,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF136AF6), Color(0xFF0D5AE0)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF136AF6).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            _showAssignmentDialog(agent);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Assign',
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFF136AF6),
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Back',
                              style: TextStyle(
                                color: Color(0xFF136AF6),
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF136AF6), Color(0xFF0D5AE0)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF136AF6).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Agent assigned successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Confirm Assignment',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
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
  }

  void _showAssignmentDialog(Map<String, dynamic> agent) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Agent'),
        content: Text('Assign complaint #${widget.complaintId} to ${agent['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${agent['name']} assigned to complaint #${widget.complaintId}'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }
}
