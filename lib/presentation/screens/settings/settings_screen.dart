import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/backend_config.dart';
import '../../../core/theme/app_tokens.dart';
import '../../providers/settings_providers.dart';
import '../../providers/tts_providers.dart';
import '../../widgets/common/soft_ui.dart';

/// Settings screen — theme, daily goal, TTS rate, API key, cache management.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Future<void> _editName(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(
      text: ref.read(settingsProvider).learnerName,
    );
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Your name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'Your first name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result != null && result.trim().isNotEmpty) {
      await ref.read(settingsProvider.notifier).setLearnerName(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: Icon(Icons.arrow_back_ios_new, size: 18, color: t.ink),
                ),
                const DisplayText('Settings', size: 24),
              ],
            ),
            const SizedBox(height: 8),

            // ── Profile ──
            const _GroupLabel('Profile'),
            _Group(
              children: [
                _Row(
                  icon: Icons.person_outline,
                  tint: t.priSoft,
                  fg: t.pri,
                  title: 'Your name',
                  subtitle: settings.learnerName.isEmpty
                      ? 'Not set'
                      : settings.learnerName,
                  onTap: () => _editName(context, ref),
                ),
              ],
            ),

            // ── Account (only when backend is configured) ──
            if (BackendConfig.isConfigured) ...[
              const _GroupLabel('Account'),
              _Group(
                children: [
                  _Row(
                    icon: Icons.manage_accounts_outlined,
                    tint: t.priSoft,
                    fg: t.pri,
                    title: 'Account, sign in & data',
                    subtitle: 'Protect, recover, export, or delete your data',
                    onTap: () => context.push('/account'),
                  ),
                ],
              ),
            ],

            // ── Appearance ──
            const _GroupLabel('Appearance'),
            _Group(
              children: [
                _Row(
                  icon: Icons.dark_mode_outlined,
                  tint: t.violetSoft,
                  fg: t.violet,
                  title: 'Theme',
                  subtitle: _themeLabel(settings.themeMode),
                  trailing: _ThemeToggle(
                    mode: settings.themeMode,
                    onChanged:
                        (m) =>
                            ref.read(settingsProvider.notifier).setThemeMode(m),
                  ),
                ),
              ],
            ),

            // ── Learning ──
            const _GroupLabel('Learning'),
            _Group(
              children: [
                _Row(
                  icon: Icons.flag_outlined,
                  tint: t.priSoft,
                  fg: t.pri,
                  title: 'Daily goal',
                  subtitle: '${settings.dailyGoalXp} XP per day',
                  trailing: DropdownButton<int>(
                    value: settings.dailyGoalXp,
                    underline: const SizedBox.shrink(),
                    style: TextStyle(
                      color: t.pri,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    onChanged: (xp) {
                      if (xp != null) {
                        ref.read(settingsProvider.notifier).setDailyGoalXp(xp);
                      }
                    },
                    items: const [
                      DropdownMenuItem(value: 20, child: Text('Casual')),
                      DropdownMenuItem(value: 50, child: Text('Regular')),
                      DropdownMenuItem(value: 100, child: Text('Serious')),
                      DropdownMenuItem(value: 150, child: Text('Intense')),
                    ],
                  ),
                ),
                _Divider(),
                _Row(
                  icon: Icons.favorite_border,
                  tint: t.redSoft,
                  fg: t.red,
                  title: 'Hearts in lessons',
                  subtitle: 'Off = practice freely',
                  trailing: Switch(
                    value: settings.heartsEnabled,
                    onChanged:
                        (v) => ref
                            .read(settingsProvider.notifier)
                            .setHeartsEnabled(v),
                  ),
                ),
              ],
            ),

            // ── Audio ──
            const _GroupLabel('Audio'),
            _Group(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                  child: Row(
                    children: [
                      IconTile(
                        icon: Icons.person_outline,
                        tint: t.priSoft,
                        fg: t.pri,
                        size: 36,
                        radius: 12,
                        iconSize: 17,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: SegmentedButton<TtsVoiceGender>(
                          segments: const [
                            ButtonSegment(
                              value: TtsVoiceGender.female,
                              label: Text('Female'),
                            ),
                            ButtonSegment(
                              value: TtsVoiceGender.male,
                              label: Text('Male'),
                            ),
                          ],
                          selected: {settings.ttsVoiceGender},
                          onSelectionChanged:
                              (selection) => ref
                                  .read(settingsProvider.notifier)
                                  .setTtsVoiceGender(selection.single),
                        ),
                      ),
                    ],
                  ),
                ),
                _Divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconTile(
                            icon: Icons.record_voice_over_outlined,
                            tint: t.amberSoft,
                            fg: t.amber,
                            size: 36,
                            radius: 12,
                            iconSize: 15,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Speech rate',
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600,
                                    color: t.ink,
                                  ),
                                ),
                                Text(
                                  '${(settings.ttsSpeechRate * 100).round()}% — slower is easier',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: t.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: settings.ttsSpeechRate,
                        min: 0.2,
                        max: 1.0,
                        divisions: 8,
                        onChanged:
                            (value) => ref
                                .read(settingsProvider.notifier)
                                .setTtsSpeechRate(value),
                      ),
                    ],
                  ),
                ),
                _Divider(),
                _Row(
                  icon: Icons.play_arrow_rounded,
                  tint: t.greenSoft,
                  fg: t.green,
                  title: 'Test voice',
                  subtitle: 'Play a sample Czech phrase',
                  onTap:
                      () =>
                          ref.read(czechTtsProvider).speak('Ahoj, jak se máš?'),
                ),
                _Divider(),
                _Row(
                  icon: Icons.delete_outline,
                  tint: t.chipBg,
                  fg: t.muted,
                  title: 'Clear audio cache',
                  subtitle: 'Remove cached audio files',
                  onTap: () async {
                    await ref.read(czechTtsProvider).clearCache();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('TTS cache cleared')),
                      );
                    }
                  },
                ),
              ],
            ),

            // ── AI configuration ──
            const _GroupLabel('Account & data'),
            _Group(
              children: [
                _Row(
                  icon: Icons.manage_accounts_outlined,
                  tint: t.priSoft,
                  fg: t.pri,
                  title: 'Account, export & deletion',
                  subtitle: 'Protect, recover, export, or delete your data',
                  onTap: () => context.push('/account'),
                ),
              ],
            ),

            // ── About ──
            const _GroupLabel('About'),
            _Group(
              children: [
                _Row(
                  icon: Icons.school_outlined,
                  tint: t.priSoft,
                  fg: t.pri,
                  title: 'Czechify',
                  subtitle: 'AI-powered Czech learning · CEFR A1 → A2',
                  trailing: const SizedBox.shrink(),
                ),
                _Divider(),
                _Row(
                  icon: Icons.code,
                  tint: t.chipBg,
                  fg: t.muted,
                  title: 'Version',
                  subtitle: '1.0.0',
                  trailing: const SizedBox.shrink(),
                ),
                _Divider(),
                _Row(
                  icon: Icons.privacy_tip_outlined,
                  tint: t.priSoft,
                  fg: t.pri,
                  title: 'Privacy Policy',
                  subtitle: 'How your data is handled',
                  onTap: () => _showPrivacyPolicy(context),
                  trailing: Icon(Icons.chevron_right, size: 15, color: t.faint),
                ),
              ],
            ),
          ],
        ),
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

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Privacy Policy'),
            content: const SingleChildScrollView(
              child: Text(
                'When the backend is enabled, Czechify creates an anonymous '
                'Supabase account, downloads curriculum, and synchronizes selected '
                'lesson, badge, streak, exam, and review-scheduling data.\n\n'
                'AI tutor and writing requests are sent through a Supabase Edge '
                'Function to DeepSeek. Chat history remains stored locally. Do '
                'not include sensitive personal information in AI prompts.\n\n'
                'Pronunciation uses the operating system speech recognizer, which '
                'may process speech on-device or through Apple/Google services. '
                'No analytics, advertising, or crash-reporting SDK is included.\n\n'
                'Account linking, portable data export, and cloud/local account '
                'deletion are available under Account & data.\n\n'
                'Full privacy policy: PRIVACY.md in the app repository.',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  final String title;
  const _GroupLabel(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 10),
      child: SectionLabel(title),
    );
  }
}

/// A rounded card grouping settings rows.
class _Group extends StatelessWidget {
  final List<Widget> children;
  const _Group({required this.children});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: t.shadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Divider(height: 1, thickness: 1, color: context.tokens.line);
}

/// A settings row: tinted icon tile, title, subtitle, optional trailing.
class _Row extends StatelessWidget {
  final IconData icon;
  final Color tint;
  final Color fg;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _Row({
    required this.icon,
    required this.tint,
    required this.fg,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            IconTile(
              icon: icon,
              tint: tint,
              fg: fg,
              size: 36,
              radius: 12,
              iconSize: 15,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: t.ink,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: t.muted,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            trailing ??
                (onTap != null
                    ? Icon(Icons.chevron_right, size: 15, color: t.faint)
                    : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}

/// Light / Auto / Dark segmented control.
class _ThemeToggle extends StatelessWidget {
  final AppThemeMode mode;
  final ValueChanged<AppThemeMode> onChanged;

  const _ThemeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    Widget seg(String label, AppThemeMode m) {
      final selected = mode == m;
      return GestureDetector(
        onTap: () => onChanged(m),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: selected ? t.card : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            boxShadow: selected ? t.shadow : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              color: selected ? t.ink : t.muted,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: t.chipBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          seg('Light', AppThemeMode.light),
          seg('Auto', AppThemeMode.system),
          seg('Dark', AppThemeMode.dark),
        ],
      ),
    );
  }
}
