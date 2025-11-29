import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/agent_service.dart';
import '../api/api_config.dart';

class AgentsSummaryPage extends StatefulWidget {
  const AgentsSummaryPage({super.key});

  @override
  State<AgentsSummaryPage> createState() => _AgentsSummaryPageState();
}

class _AgentsSummaryPageState extends State<AgentsSummaryPage> {
  final AgentService _agentService = AgentService();
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _agents = [];
  List<dynamic> _filteredAgents = [];
  bool _isLoading = true;
  String? _error;
  String? _baseUrl;

  // Map department enum values to display names
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
      case 'OTHER':
        return 'Other';
      default:
        return department;
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterAgents);
    _initializeBaseUrl();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeBaseUrl() async {
    try {
      final url = await ApiConfig.getBaseUrl();
      if (mounted) {
        setState(() {
          _baseUrl = url;
        });
        _fetchAgents();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _baseUrl = ApiConfig.defaultBaseUrl;
        });
        _fetchAgents();
      }
    }
  }

  Future<void> _fetchAgents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = await _agentService.getAllUserAgents();

    if (response.success && response.data != null) {
      setState(() {
        _agents = response.data!;
        _filteredAgents = _agents;
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = response.error ?? 'Failed to load agents';
        _isLoading = false;
      });
    }
  }

  void _filterAgents() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredAgents = _agents;
      } else {
        _filteredAgents = _agents.where((agent) {
          final name = (agent['name'] as String? ?? '').toLowerCase();
          return name.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _copyToClipboard(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$label copied to clipboard'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String _getFullDocumentUrl(String? documentPath) {
    if (documentPath == null || documentPath.isEmpty) {
      return '';
    }
    // If it's already a full URL, return as is
    if (documentPath.startsWith('http://') || documentPath.startsWith('https://')) {
      return documentPath;
    }
    // Otherwise, construct full URL
    final baseUrl = _baseUrl ?? ApiConfig.defaultBaseUrl;
    // Remove leading slash from documentPath if baseUrl already ends with /
    final cleanPath = documentPath.startsWith('/') ? documentPath.substring(1) : documentPath;
    return '$baseUrl/$cleanPath';
  }

  void _showDocumentPreview(String documentUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Document Preview',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111318),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        color: Colors.grey.shade700,
                      ),
                    ],
                  ),
                ),
                // Document content
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        documentUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF136AF6),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Colors.red.shade300,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Failed to load document',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF5F708C),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                // Footer with open in browser button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _copyToClipboard(documentUrl, 'Document URL');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF136AF6),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Copy Document URL',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Agents Summary',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
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
                      onPressed: _fetchAgents,
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 24,
                      ),
                      tooltip: 'Refresh',
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7F8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search agents by name...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 15,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey.shade600,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: Colors.grey.shade600,
                            ),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF111318),
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF136AF6),
                        ),
                      ),
                    )
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _error!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF5F708C),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: _fetchAgents,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF136AF6),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Retry',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
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
                                    Icons.people_outline,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _searchController.text.isNotEmpty
                                        ? 'No agents found matching "${_searchController.text}"'
                                        : 'No agents found',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF5F708C),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_filteredAgents.length} agent${_filteredAgents.length == 1 ? '' : 's'} found',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: _filteredAgents.length,
                                    itemBuilder: (context, index) {
                                      final agent = _filteredAgents[index] as Map<String, dynamic>;
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 16),
                                        child: _buildAgentCard(agent),
                                      );
                                    },
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

  Widget _buildAgentCard(Map<String, dynamic> agent) {
    final name = agent['name'] as String? ?? 'N/A';
    final phone = agent['phone'] as String? ?? 'N/A';
    final password = agent['password'] as String? ?? 'N/A';
    final department = _getDepartmentDisplayName(agent['department'] as String?);
    final documentPath = agent['document'] as String?;
    final hasDocument = documentPath != null && documentPath.isNotEmpty;
    final documentUrl = hasDocument ? _getFullDocumentUrl(documentPath) : '';
    final profilePhotoUrl = agent['profilePhotoUrl'] as String?;
    final hasProfilePhoto = profilePhotoUrl != null && profilePhotoUrl.isNotEmpty;
    final profilePhotoFullUrl = hasProfilePhoto ? _getFullDocumentUrl(profilePhotoUrl) : '';
    final assignedComplaint = agent['assignedComplaint'] as int? ?? 0;
    final complaintsInProgress = agent['complaintsInProgress'] as int? ?? 0;
    final closedComplaints = agent['closedComplaints'] as int? ?? 0;

    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Agent Information Section
            Row(
              children: [
                // Profile Photo or Avatar
                if (hasProfilePhoto)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.network(
                      profilePhotoFullUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF136AF6), Color(0xFF0D5AE0)],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF136AF6), Color(0xFF0D5AE0)],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'A',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF136AF6), Color(0xFF0D5AE0)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'A',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111318),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            phone,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Department
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF136AF6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.business,
                    size: 16,
                    color: const Color(0xFF136AF6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    department,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF136AF6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Password Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7F8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          password,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF111318),
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF136AF6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () => _copyToClipboard(password, 'Password'),
                      icon: const Icon(
                        Icons.copy,
                        size: 18,
                        color: Color(0xFF136AF6),
                      ),
                      tooltip: 'Copy password',
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Document Section
            if (hasDocument)
              GestureDetector(
                onTap: () => _showDocumentPreview(documentUrl),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7F8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          documentUrl,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 48,
                              height: 48,
                              color: Colors.grey.shade200,
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                      Color(0xFF136AF6),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 48,
                              height: 48,
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.description,
                                size: 24,
                                color: Color(0xFF5F708C),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Document',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Text(
                                  'View Document',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF136AF6),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.open_in_new,
                                  size: 16,
                                  color: Color(0xFF136AF6),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 20,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'No document available',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            
            // Complaint Statistics Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7F8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.assignment,
                        size: 16,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Complaint Statistics',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111318),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          'Assigned',
                          assignedComplaint.toString(),
                          Colors.orange,
                          Icons.assignment_outlined,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _buildStatItem(
                          'In Progress',
                          complaintsInProgress.toString(),
                          Colors.blue,
                          Icons.work_outline,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _buildStatItem(
                          'Closed',
                          closedComplaints.toString(),
                          Colors.green,
                          Icons.check_circle_outline,
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

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
