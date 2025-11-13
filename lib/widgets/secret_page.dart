import 'package:flutter/material.dart';

// Empty Facebook Page
class FacebookPage extends StatelessWidget {
  const FacebookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF1E293B),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Facebook',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.facebook,
              size: 80,
              color: const Color(0xFF1877F2).withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'Facebook Page',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B).withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This page is empty',
              style: TextStyle(
                fontSize: 16,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
