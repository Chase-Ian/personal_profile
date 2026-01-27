import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('Home Tab'),
          SizedBox(height: 10),
          Text('Replace this with About / Education / Gallery / Contact tabs later'),
        ],
      ),
    );
  }
}
