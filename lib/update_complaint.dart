import 'package:flutter/material.dart';

class UpdateComplaintPage extends StatefulWidget {
  final String complaintId;

  const UpdateComplaintPage({
    super.key,
    required this.complaintId,
  });

  @override
  State<UpdateComplaintPage> createState() => _UpdateComplaintPageState();
}

class _UpdateComplaintPageState extends State<UpdateComplaintPage> {
  String _selectedStatus = 'Mark as Started';
  final TextEditingController _noteController = TextEditingController();
  bool _showOfflineSync = true;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7F8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top bar
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Color(0xFF111318),
                          size: 20,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.more_vert,
                          color: Color(0xFF111318),
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Complaint #C-1701',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111318),
                      letterSpacing: -0.015,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Pothole on Main Street',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF6C757D),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chips
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildChip('Pothole', const Color(0xFFE5E7EB), const Color(0xFF111318)),
                        _buildChip('High', const Color(0xFFDC3545).withOpacity(0.2), const Color(0xFFDC3545)),
                        _buildChip('New', const Color(0xFF136AF6).withOpacity(0.2), const Color(0xFF136AF6)),
                      ],
                    ),
                  ),

                  // Offline Sync Indicator
                  if (_showOfflineSync)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFD7E14).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.sync_problem,
                              color: Color(0xFFFD7E14),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Pending upload — 3 items to sync',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFFD7E14),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _showOfflineSync = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Sync retrying...'),
                                    backgroundColor: Color(0xFF136AF6),
                                  ),
                                );
                              },
                              child: const Text(
                                'Retry',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFD7E14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Media Carousel
                  _buildMediaCarousel(),

                  const SizedBox(height: 16),

                  // Map Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 192,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: const DecorationImage(
                              image: NetworkImage(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuBbTq_mIjDzTs00cFylZ7ikI0_AiBkskMlPe0kdS3nwl2tMobqC2ZKdTVc51IVjF3cBU17BDJ0Yi5taC9c2-APUUTufWy6k-YRVh3dV8vv8etQD2h59k7wQ75Tf6hIf84wby6lG_KHtpcsNHdUGz2D95pCG8xMawLCBtuu-t0w1tGZZM2wSUdatMxgJyC5l2IuXFqFMkxxlU80l7EQX1sG7xxZu3rqxnig72HndM1-NPFgekZTP3PaRi11NbyUN_qEygrB-L2QzzA',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.open_in_new, size: 18),
                                label: const Text(
                                  'Open in Maps',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF136AF6),
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFF136AF6),
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.navigation, size: 18),
                                label: const Text(
                                  'Start Navigation',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF136AF6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // AI Helper Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF136AF6).withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFF136AF6).withOpacity(0.1),
                      ),
                      child: Stack(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                color: Color(0xFF136AF6),
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Another high-priority complaint is 0.5 miles away. Completing it next could save you 15 minutes. View route.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF136AF6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.close,
                                size: 18,
                                color: Color(0xFF136AF6),
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Details
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111318),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'A large and dangerous pothole has formed in the middle of the road, causing issues for traffic. It\'s approximately 2 feet wide and several inches deep. Multiple cars have been seen swerving to avoid it.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6C757D),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildInfoRow('Reported by:', 'Citizen A'),
                        const SizedBox(height: 8),
                        _buildInfoRow('Reported on:', 'Oct 26, 2023, 10:30 AM'),
                        const SizedBox(height: 8),
                        _buildInfoRow('Last Updated:', 'Oct 26, 2023, 11:00 AM'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Activity Log
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Activity Log',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111318),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Stack(
                          children: [
                            // Timeline line
                            Positioned(
                              left: 10,
                              top: 20,
                              bottom: 0,
                              child: Container(
                                width: 2,
                                color: Colors.grey[300],
                              ),
                            ),
                            // Timeline items
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTimelineItem(
                                  'Assigned to Agent',
                                  'Oct 26, 2023, 11:00 AM',
                                  'Assigned to John Doe.',
                                  true,
                                ),
                                const SizedBox(height: 24),
                                _buildTimelineItem(
                                  'Complaint Raised',
                                  'Oct 26, 2023, 10:30 AM',
                                  null,
                                  false,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 120), // Space for bottom panel
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom sticky action panel
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7F8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status dropdown
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Update Status',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6C757D),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey[300]!,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedStatus,
                      isExpanded: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      items: const [
                        DropdownMenuItem(
                          value: 'Mark as Started',
                          child: Text('Mark as Started'),
                        ),
                        DropdownMenuItem(
                          value: 'Mark as In Progress',
                          child: Text('Mark as In Progress'),
                        ),
                        DropdownMenuItem(
                          value: 'Mark as Fixed',
                          child: Text('Mark as Fixed'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedStatus = value;
                          });
                        }
                      },
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF111318),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Notes
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Note (Optional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6C757D),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    controller: _noteController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Add progress, ETA, etc.',
                      hintStyle: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF111318),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Upload after photos
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 2,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text(
                    'Upload at least one after-photo before marking this complaint as Fixed.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6C757D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      // Handle photo upload
                    },
                    icon: const Icon(
                      Icons.upload_file,
                      size: 18,
                    ),
                    label: const Text(
                      'Upload After Photo',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF136AF6),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFF136AF6),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Update submitted successfully'),
                      backgroundColor: Color(0xFF136AF6),
                    ),
                  );
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF136AF6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Submit Update',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildMediaCarousel() {
    return SizedBox(
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildMediaItem(
            imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBHZYp6h5e6ZwiuJSiIANDCDVOR0Nm8PMgexrCfhBLf5FpNfs0B2QgVd55t9GDD3qPYb_aUgKXtSHiFWp1B20rrG9zFeMJ_cE908d6Co6UsvmC6fDaeBtQ-N0RFAwZSVkaVV_J0Bl5j_RUJJTzUs3x5L013_qNwqiD0JVoQAFWqqKEQFv2BqRS0rqmxfhyC-F4BJnJ41SuhnjNEnfPR-isW6f1WhQv4gljBo4GXFqbKEwN6yAoF4SPCTuyZ-QkfoBA7d4i_t34-Dw',
            label: 'Before Photo',
            sublabel: 'View in full screen',
          ),
          const SizedBox(width: 12),
          Container(
            width: 200,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_circle,
                  size: 48,
                  color: Colors.grey[600],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Before Video',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111318),
                  ),
                ),
                const Text(
                  'Play video',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6C757D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaItem({
    required String imageUrl,
    required String label,
    required String sublabel,
  }) {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 128,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF111318),
            ),
          ),
          Text(
            sublabel,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6C757D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF6C757D),
        ),
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          const TextSpan(text: ' '),
          TextSpan(
            text: value,
            style: const TextStyle(
              color: Color(0xFF111318),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String date,
    String? description,
    bool isFilled,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: isFilled
                ? const Color(0xFF136AF6)
                : Colors.grey[300],
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
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111318),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6C757D),
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6C757D),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

