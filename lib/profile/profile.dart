import 'package:flutter/material.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile header placeholder
          Container(
            height: 200,
            width: double.infinity,
            color: Colors.green,
            child: const Center(
              child: Text(
                'Profile Header Placeholder',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Profile options
          ElevatedButton(
            onPressed: () {
              // Placeholder: navigate to edit profile
            },
            child: const Text('Edit Profile'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Change Password'),
          ),

          const SizedBox(height: 20),
          const Text(
            'Profile Content Placeholder',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
