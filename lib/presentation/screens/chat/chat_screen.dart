import 'package:flutter/material.dart';
import '../../widgets/common/record_button.dart';

/// AI conversation screen — role-play scenarios with AI tutor.
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Tutor')),
      body: Column(
        children: [
          const Expanded(
            child: Center(
              child: Text('Conversation will appear here'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: RecordButton(
              onPressed: () {
                // TODO: Start recording + transcription + LLM call
              },
            ),
          ),
        ],
      ),
    );
  }
}