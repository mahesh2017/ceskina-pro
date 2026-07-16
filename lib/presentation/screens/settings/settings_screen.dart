import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_providers.dart';
import '../../providers/tts_providers.dart';
import '../../providers/llm_providers.dart';

/// Settings screen — theme, daily goal, TTS rate, API key, cache management.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _apiKeyController = TextEditingController();
  bool _obscureApiKey = true;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // ── Appearance ──
          _SectionHeader(title: 'Appearance'),
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Theme'),
            subtitle: Text(_themeLabel(settings.themeMode)),
            trailing: DropdownButton<AppThemeMode>(
              value: settings.themeMode,
              onChanged: (mode) {
                if (mode != null) {
                  ref.read(settingsProvider.notifier).setThemeMode(mode);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: AppThemeMode.system,
                  child: Text('System'),
                ),
                DropdownMenuItem(
                  value: AppThemeMode.light,
                  child: Text('Light'),
                ),
                DropdownMenuItem(
                  value: AppThemeMode.dark,
                  child: Text('Dark'),
                ),
              ],
            ),
          ),
          const Divider(),

          // ── Learning ──
          _SectionHeader(title: 'Learning'),
          ListTile(
            leading: const Icon(Icons.flag),
            title: const Text('Daily Goal'),
            subtitle: Text('${settings.dailyGoalXp} XP per day'),
            trailing: DropdownButton<int>(
              value: settings.dailyGoalXp,
              onChanged: (xp) {
                if (xp != null) {
                  ref.read(settingsProvider.notifier).setDailyGoalXp(xp);
                }
              },
              items: const [
                DropdownMenuItem(value: 20, child: Text('20 XP — Casual')),
                DropdownMenuItem(value: 50, child: Text('50 XP — Regular')),
                DropdownMenuItem(value: 100, child: Text('100 XP — Serious')),
                DropdownMenuItem(value: 150, child: Text('150 XP — Intense')),
              ],
            ),
          ),
          const Divider(),

          // ── Audio ──
          _SectionHeader(title: 'Audio'),
          ListTile(
            leading: const Icon(Icons.record_voice_over),
            title: const Text('TTS Speech Rate'),
            subtitle: Text('${(settings.ttsSpeechRate * 100).round()}% (slower = easier)'),
            trailing: SizedBox(
              width: 120,
              child: Slider(
                value: settings.ttsSpeechRate,
                min: 0.2,
                max: 1.0,
                divisions: 8,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setTtsSpeechRate(value);
                },
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.volume_up),
            title: const Text('Test TTS'),
            subtitle: const Text('Play a sample Czech phrase'),
            onTap: () {
              ref.read(czechTtsProvider).speak('Ahoj, jak se máš?');
            },
          ),
          ListTile(
            leading: const Icon(Icons.cleaning_services),
            title: const Text('Clear TTS Cache'),
            subtitle: const Text('Remove cached audio files'),
            onTap: () async {
              await ref.read(czechTtsProvider).clearCache();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('TTS cache cleared')),
                );
              }
            },
          ),
          const Divider(),

          // ── AI / API Keys ──
          _SectionHeader(title: 'AI Configuration'),
          ListTile(
            leading: Icon(
              Icons.key,
              color: settings.hasApiKey ? Colors.green : Colors.orange,
            ),
            title: const Text('DeepSeek API Key'),
            subtitle: Text(
              settings.hasApiKey
                  ? 'API key configured ✓'
                  : 'No API key set — using mock responses',
            ),
            onTap: () => _showApiKeyDialog(),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About DeepSeek'),
            subtitle: const Text(
              'Get a free API key at platform.deepseek.com',
            ),
            onTap: () {
              // Could open URL here
            },
          ),
          const Divider(),

          // ── About ──
          _SectionHeader(title: 'About'),
          const ListTile(
            leading: Icon(Icons.school),
            title: Text('Čeština Pro'),
            subtitle: Text('AI-powered Czech learning app\nCEFR A1 → A2'),
          ),
          const ListTile(
            leading: Icon(Icons.code),
            title: Text('Version'),
            subtitle: Text('1.0.0 — Phase 4'),
          ),
        ],
      ),
    );
  }

  String _themeLabel(AppThemeMode mode) {
    return switch (mode) {
      AppThemeMode.system => 'System default',
      AppThemeMode.light => 'Light',
      AppThemeMode.dark => 'Dark',
    };
  }

  void _showApiKeyDialog() {
    _apiKeyController.clear();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            title: const Text('DeepSeek API Key'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Enter your DeepSeek API key to enable AI conversation and writing evaluation.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _apiKeyController,
                  obscureText: _obscureApiKey,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'API Key',
                    hintText: 'sk-...',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureApiKey
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => _obscureApiKey = !_obscureApiKey);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Get a free key at platform.deepseek.com',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              if (ref.read(settingsProvider).hasApiKey)
                TextButton(
                  onPressed: () async {
                    await ref.read(settingsProvider.notifier).clearApiKey();
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Remove'),
                ),
              FilledButton(
                onPressed: () async {
                  final key = _apiKeyController.text.trim();
                  if (key.isNotEmpty) {
                    await ref.read(settingsProvider.notifier).setApiKey(key);
                    if (ctx.mounted) Navigator.pop(ctx);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}