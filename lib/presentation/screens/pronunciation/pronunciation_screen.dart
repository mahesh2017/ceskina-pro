import 'package:flutter/material.dart';

/// Pronunciation lab — record-and-compare with visual feedback.
class PronunciationScreen extends StatelessWidget {
  final String exerciseId;

  const PronunciationScreen({super.key, required this.exerciseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pronunciation Lab')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mic, size: 64),
            SizedBox(height: 16),
            Text('Pronunciation Practice'),
            Text('Record and get feedback on ř, ě, vowel length',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}