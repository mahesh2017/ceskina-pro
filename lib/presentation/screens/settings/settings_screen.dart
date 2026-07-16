import 'package:flutter/material.dart';

/// Settings screen — TTS voice, STT engine, API keys, theme, daily goal.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.key),
            title: const Text('API Keys'),
            subtitle: const Text('DeepSeek, OpenAI, Google TTS'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.record_voice_over),
            title: const Text('TTS Voice'),
            subtitle: const Text('Czech voice selection'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.mic),
            title: const Text('STT Engine'),
            subtitle: const Text('Vosk (offline) / Whisper (cloud)'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Theme'),
            subtitle: const Text('Dark / Light / System'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.flag),
            title: const Text('Daily Goal'),
            subtitle: const Text('50 XP'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}