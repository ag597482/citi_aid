import 'package:flutter/material.dart';

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
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Content Header
                    Text(
                      'Large Pothole on Main Street',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1C1C1E),
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
                          child: const Center(
                            child: Text(
                              'Road Hazard',
                              style: TextStyle(
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
                                color: const Color(0xFFFF3B30),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'High Severity',
                              style: TextStyle(
                                color: Color(0xFFFF3B30),
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
                              image: const DecorationImage(
                                image: NetworkImage(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuDVPuKtGw8WvZDcQ2SW5qB1QUaGWn42xIyeyR2lIVEDKPkI8TCQr5c5bed6rZMjSdTr1niMM7OOB_RWUn6WPRkC4ATExE4rijLHVzGyXHibKBnJPnxsvC2N_aNNqNHYXUkaEGvHqUgtREUXIPyQsJbsc_sGmJO8_Xup7RLji4ANfD3eoT_2uP8ecb2X0GeXKYfG0-Ff82sShMvFDlTcT4lIfS0RYj0gZfzql1557bUT8uunCiyXWeJ8MY3bhQTH90ieLR87iK14XQ',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            width: 280,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: const DecorationImage(
                                image: NetworkImage(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuAThlNIC0OT6PUA9tB2Z4_0BLkD4MyuRmn11bUgsh4DvJK5wbb9MPQ43_HyfnlDfJQsk1xZ66W6mVBHBNI58bjOLjsmY8yaCuykDFfXC_i0-cbIFBt0fBF8_kLl1zWCJxRijsbR8S5G5g77AICJbopSWArkOtDxrdMTdY5b8Mk6XCLxOnTmVhcsPKi8GSjq0T8zdIy4konLXIJnQJIH9tt545lwV86I3NjpcevWJk2w-ztfS1TW5Hf9knmvBERc5X_6yfxj9kCdPA',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            width: 280,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1F2937),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.play_circle,
                                color: Colors.white,
                                size: 60,
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
                          content: 'There is a large pothole in the middle of Main Street, right in front of the public library. It has been there for a week and is getting bigger. It\'s a danger to cars and cyclists.',
                        ),

                        const SizedBox(height: 16),

                        // Location
                        _buildLocationSection(),

                        const SizedBox(height: 16),

                        // Reporter
                        _buildInfoSection(
                          icon: Icons.person,
                          title: 'Reporter',
                          content: 'Reported 2 days ago by Jane P.',
                        ),

                        const SizedBox(height: 16),

                        // Assigned Agent
                        _buildAgentSection(),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Status Timeline
                    _buildStatusTimeline(),

                    const SizedBox(height: 24),

                    // CTA Bar
                    _buildCTABar(),

                    const SizedBox(height: 24),

                    // Comments Section
                    _buildCommentsSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

  Widget _buildLocationSection() {
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
            Icons.location_on,
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
                'Location',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '123 Main St, Anytown, USA',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8E8E93),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 128,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDjAKMGwvog-7UpKQtMECqFGwd6XEIKbgmNlJ8xX8CiNtNSJHH7utnU81NedpPpZVJ1AQHfGNN4cmeQvon0gI0mOX-0kFW9czy39ySnE2yX2Rg4YtwScEkfyoCG2hZqZYQMUFUPRfUb0jX7EaMUJHaKjKCaQmYiFqhvIZkU0jbgt2SvESGldpc70zgUh1LF5jv2-qDCs4Sh__IjVZPNoMcbS5bX73KQKqTjStcLL-et0uxUYDDOtQOQk3teHgdZjfvpzdbAwgfDEA',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Opening in Maps...'),
                        backgroundColor: Color(0xFF007AFF),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Open in Maps',
                    style: TextStyle(
                      color: Colors.white,
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

  Widget _buildAgentSection() {
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
              const Text(
                'Assigned to John Smith (Public Works)',
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

  Widget _buildStatusTimeline() {
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
        Container(
          padding: const EdgeInsets.only(left: 32),
          child: Column(
            children: [
              _buildTimelineItem(
                title: 'Agent Assigned',
                date: 'Mar 17, 2024, 10:00 AM',
                description: '"John Smith from Public Works has been assigned to this issue."',
              ),
              const SizedBox(height: 24),
              _buildTimelineItem(
                title: 'Acknowledged',
                date: 'Mar 16, 2024, 2:30 PM',
              ),
              const SizedBox(height: 24),
              _buildTimelineItem(
                title: 'Submitted',
                date: 'Mar 15, 2024, 9:05 AM',
              ),
            ],
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFF8E8E93), width: 0.2),
          bottom: BorderSide(color: Color(0xFF8E8E93), width: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF136AF6), Color(0xFF0D5AE0)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF136AF6).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sharing complaint...'),
                          backgroundColor: Color(0xFF136AF6),
                        ),
                      );
                    },
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('Share'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Following complaint...'),
                          backgroundColor: Color(0xFF136AF6),
                        ),
                      );
                    },
                    icon: const Icon(Icons.notifications, size: 18, color: Color(0xFF136AF6)),
                    label: const Text('Follow', style: TextStyle(color: Color(0xFF136AF6))),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reporting duplicate...'),
                          backgroundColor: Color(0xFF136AF6),
                        ),
                      );
                    },
                    icon: const Icon(Icons.control_point_duplicate, size: 18, color: Color(0xFF136AF6)),
                    label: const Text('Report Duplicate', style: TextStyle(color: Color(0xFF136AF6))),
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
          const SizedBox(height: 8),
          Row(
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Editing complaint...'),
                          backgroundColor: Color(0xFF136AF6),
                        ),
                      );
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
                            title: const Text('Close Complaint'),
                            content: const Text('Are you sure you want to close this complaint?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Complaint closed'),
                                      backgroundColor: Color(0xFFFF3B30),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Close',
                                  style: TextStyle(color: Color(0xFFFF3B30)),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.close, size: 18, color: Colors.red),
                    label: const Text('Close Complaint', style: TextStyle(color: Colors.red)),
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
        ],
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comments (3)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1C1C1E),
          ),
        ),
        const SizedBox(height: 16),
        _buildComment(
          avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCVe9BFBaBWDfcx1d6G5lM6piASMoa1wA1LeLElC8AuSJ9-KJTCQutjhLRNBrIQhtUXAXu0KPwYoJS2XdW2x_qT-6j35wHs1FNzatvX7SQ-ZhixrxbNqEdpKfnD5KsWBuweoB_frKRl1U-ybNg21t8M4eK2Oirt5HLJL91wJUE4arhTTuJG4TjJjPjKxbsAj523HRxq-cwhPrvB2IoUNmBPsCj-hVlaY7R8UHbwL0n_pGdLRvk1a2ACil60_o-C8zYA5QeTU_gzeQ',
          name: 'Alex R.',
          comment: 'Thanks for reporting this! I almost blew a tire here yesterday.',
          time: '1 day ago',
        ),
        const SizedBox(height: 16),
        _buildComment(
          avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC8XFswwAX9Elc_i7nJQWcm1NTS0wYZ-JnYkbFVBPFyBhDR77Yh-GV0yrmxdSLRHy0zsEY-QUGWvRsLSs6TOhyAg82n_J8pZ0gcRu8oqWSi5fWW9d8-0w82WSBccmBdzVcUvx8yAYgpjva5EK_opYVhD8Um20jxHCveDj-TcYpSfaiDjVqQynr5bY-8gff8V1dB0VoPh1cR9O-KmpszItY53HpNSIq0RfAmZVB4Ky_VdNOMr-EKFLqKmHhjo9_NS601CRC2ujsPCw',
          name: 'Maria G.',
          comment: 'I called the city about this too. Glad to see it\'s officially logged.',
          time: '18 hours ago',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuAagrQyHhPz1-7x9B5FveKAc1PGr2QQtJjEfOtfomcMJOn6RBBOyxaeF67GP2hcB7d84M4rEU4TW60Chr6RjkPLAgQSuDzmTSUveZArlH8XFLzDlJPpDE6zFRFlJGP7yLLqAQNOaCZQmVpgfBINtcDwuRz9rTGtuqXVIlo2YqdtlcAqAK-eMV-SjNRSOljFqMIkH38Zaj0u3UQr48p0wza6a0QDv1AlycAUfSraHkT5wWJ3ciuekZ124V537yUss10lCEMFZrbeSQ',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: 'Add a comment...',
                  hintStyle: TextStyle(color: Color(0xFF8E8E93)),
                  filled: true,
                  fillColor: Color(0xFFF5F7F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 48,
              height: 48,
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
              child: IconButton(
                onPressed: () {
                  if (_commentController.text.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Comment added!'),
                        backgroundColor: Color(0xFF136AF6),
                      ),
                    );
                    _commentController.clear();
                  }
                },
                icon: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComment({
    required String avatar,
    required String name,
    required String comment,
    required String time,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: NetworkImage(avatar),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7F8),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8E8E93),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
