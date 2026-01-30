import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile picture
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, size: 60, color: Colors.white),
          ),

          const SizedBox(height: 16),

          // Full name
          const Text(
            'Chase Ian Famisaran',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Short bio
          const Text(
            'Hello, I;m a student from IT241',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),

          const SizedBox(height: 24),

          // Contact information
          _sectionTitle('Contact Information'),
          _centerInfoRow(Icons.email, 'clfamisaram@student.apc.edu.ph'),
          _centerInfoRow(Icons.phone, '+63 927 399 2646'),
          _centerInfoRow(Icons.link, 'https://github.com/Chase-Ian'),

          const SizedBox(height: 24),

          // Other personal details
          _sectionTitle('Personal Details'),
          _centerInfoBlock('Skills', 'Flutter, Dart, Supabase, Firebase'),
          _centerInfoBlock('Hobbies', 'hanging out with friends, Gaming'),
          _centerInfoBlock('Interests', 'game development'),
        ],
      ),
    );
  }

  // Section title (centered)
  static Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Centered contact row
  static Widget _centerInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  // Centered personal detail block
  static Widget _centerInfoBlock(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            content,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
