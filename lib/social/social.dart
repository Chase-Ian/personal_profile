import 'package:flutter/material.dart';

class SocialTab extends StatelessWidget {
  const SocialTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Social'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Friends'),
              Tab(text: 'Add Friend'),
              Tab(text: 'Chats'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('Friends Tab Placeholder')),
            Center(child: Text('Add Friend Tab Placeholder')),
            Center(child: Text('Chats Tab Placeholder')),
          ],
        ),
      ),
    );
  }
}
