import 'package:flutter/material.dart';
import '../../../domain/entities/enums.dart';

/// Mock exam screen — timed sections matching CCE format.
class MockExamScreen extends StatelessWidget {
  final ExamLevel level;

  const MockExamScreen({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mock Exam — ${level.name.toUpperCase()}')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment, size: 64),
            const SizedBox(height: 16),
            Text('CCE-${level.name.toUpperCase()} Mock Exam'),
            const Text('Timed sections: Reading, Listening, Writing, Speaking',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {},
              child: const Text('Start Exam'),
            ),
          ],
        ),
      ),
    );
  }
}