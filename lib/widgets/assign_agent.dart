import 'package:flutter/material.dart';
import '../services/agent_service.dart';
import '../services/complaint_service.dart';
import '../api/api_response.dart';

class AssignAgentPage extends StatefulWidget {
  final String complaintId;
  
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
  final AgentService _agentService = AgentService();
  final ComplaintService _complaintService = ComplaintService();

  List<Map<String, dynamic>> _allAgents = [];
  List<Map<String, dynamic>> _filteredAgents = [];
  String? _complaintDepartment;
  bool _isLoading = true;
  bool _isAssigning = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterAgents);
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Load complaint details and agents
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load complaint to get department for filtering
      final complaintResponse = await _complaintService.getComplaintById(
        widget.complaintId,
      );

      if (complaintResponse.success && complaintResponse.data != null) {
        final complaint = complaintResponse.data!;
        _complaintDepartment = complaint['department'] as String?;
      }

      // Load agents (will use department-based API for suggested agents)
      await _loadAgents();
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  /// Load agents from API based on selected view
  Future<void> _loadAgents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      ApiResponse<List<dynamic>> response;

      // Use department-based API for suggested agents, all agents API for all agents view
      if (_selectedView == 'Suggested Agents' && _complaintDepartment != null) {
        response = await _agentService.getAgentsByDepartment(_complaintDepartment!);
      } else {
        response = await _agentService.getAllUserAgents();
      }

      if (response.success && response.data != null) {
        final agentsList = response.data as List;
        setState(() {
          _allAgents = agentsList
              .map((json) => json as Map<String, dynamic>)
              .toList();
          _filterAgents();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.error ?? 'Failed to load agents';
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

  /// Filter agents based on search query
  /// Note: For "Suggested Agents", the API already filters by department,
  /// so we only need to filter by search query here
  void _filterAgents() {
    final query = _searchController.text.toLowerCase().trim();
    List<Map<String, dynamic>> agentsToFilter = _allAgents;

    // Filter by search query
    if (query.isNotEmpty) {
      agentsToFilter = agentsToFilter.where((agent) {
        final name = (agent['name'] as String? ?? '').toLowerCase();
        final department = (agent['department'] as String? ?? '').toLowerCase();
        return name.contains(query) || department.contains(query);
      }).toList();
    }

    setState(() {
      _filteredAgents = agentsToFilter;
    });
  }

  /// Get department display name
  String _getDepartmentDisplayName(String? department) {
    if (department == null) return 'N/A';
    switch (department.toUpperCase()) {
      case 'ELECTRICITY':
        return 'Electricity';
      case 'POTHOLES':
        return 'Potholes';
      case 'DRAINAGE':
        return 'Drainage';
      case 'GARBAGE':
        return 'Garbage';
      case 'SANITATION':
        return 'Sanitation';
      case 'PUBLIC_WORKS':
      case 'PUBLICWORKS':
        return 'Public Works';
      case 'PARKS_REC':
      case 'PARKSREC':
        return 'Parks & Rec';
      default:
        return department;
    }
  }

  /// Get agent avatar URL or default
  String _getAgentAvatar(Map<String, dynamic> agent) {
    // You can add avatar field to agent model if available
    // For now, return a default avatar URL or use initials
    return 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(agent['name'] as String? ?? 'Agent')}&background=136AF6&color=fff';
  }

  /// Assign agent to complaint
  Future<void> _assignAgent(Map<String, dynamic> agent) async {
    final agentId = agent['id'] as String?;
    if (agentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid agent ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isAssigning = true;
    });

    try {
      final response = await _complaintService.assignAgentToComplaint(
        complaintId: widget.complaintId,
        agentId: agentId,
      );

      if (response.success) {
        if (mounted) {
          Navigator.of(context).pop(true); // Return true to indicate success
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${agent['name']} assigned to complaint successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.error ?? 'Failed to assign agent'),
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
    } finally {
      if (mounted) {
        setState(() {
          _isAssigning = false;
        });
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
                      onTap: () {
                        setState(() => _selectedView = 'Suggested Agents');
                        _loadAgents(); // Reload agents using department-based API
                      },
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
                      onTap: () {
                        setState(() => _selectedView = 'All Agents');
                        _loadAgents(); // Reload agents using all agents API
                      },
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
                              onPressed: _loadData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF136AF6),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredAgents.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person_off_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _selectedView == 'Suggested Agents'
                                      ? 'No suggested agents found'
                                      : 'No agents found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadAgents,
                            color: const Color(0xFF136AF6),
                            child: ListView.builder(
                              padding: const EdgeInsets.only(top: 16),
                              itemCount: _filteredAgents.length + 1,
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    child: Text(
                                      _selectedView == 'Suggested Agents'
                                          ? 'Suggested Agents'
                                          : 'All Agents',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF111318),
                                      ),
                                    ),
                                  );
                                }

                                final agent = _filteredAgents[index - 1];

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
                                          color: const Color(0xFF136AF6).withOpacity(0.1),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(30),
                                          child: Image.network(
                                            _getAgentAvatar(agent),
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF136AF6).withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(30),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    (agent['name'] as String? ?? 'A')[0].toUpperCase(),
                                                    style: const TextStyle(
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF136AF6),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              agent['name'] as String? ?? 'N/A',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF111318),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _getDepartmentDisplayName(agent['department'] as String?),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF5F708C),
                                              ),
                                            ),
                                            if (agent['phone'] != null) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                agent['phone'] as String,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF94A3B8),
                                                ),
                                              ),
                                            ],
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
                                          onPressed: _isAssigning ? null : () {
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Assign Agent',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assign complaint to ${agent['name']}?',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1E293B),
              ),
            ),
            if (agent['department'] != null) ...[
              const SizedBox(height: 8),
              Text(
                'Department: ${_getDepartmentDisplayName(agent['department'] as String?)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _isAssigning
                ? null
                : () {
                    Navigator.pop(context);
                    _assignAgent(agent);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF136AF6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isAssigning
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Assign',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
