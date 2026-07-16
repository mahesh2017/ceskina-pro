import 'package:flutter/material.dart';

/// Stats / progress screen — CEFR level, mastery breakdown, badges.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 64),
            SizedBox(height: 16),
            Text('Your Progress'),
            Text('CEFR level estimate, case mastery, badges',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}