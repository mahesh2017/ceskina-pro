import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_tokens.dart';
import '../../providers/curriculum_providers.dart';
import '../../providers/gamification_providers.dart';
import '../../providers/review_providers.dart';
import '../../providers/settings_providers.dart';
import '../../widgets/common/soft_ui.dart';
import '../../widgets/common/learning_tip_card.dart';

/// Home dashboard — greeting, daily goal hero, continue learning, quick
/// actions and shortcuts. Redesigned per the "Calm & premium" handoff.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final g = ref.watch(gamificationProvider);
    final settings = ref.watch(settingsProvider);
    final dueCount = ref.watch(dueCardCountProvider).value ?? 0;

    // Time-aware greeting + personalized name.
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Dobré ráno'
        : hour < 18
            ? 'Dobré odpoledne'
            : 'Dobrý večer';
    final name = settings.learnerName.isNotEmpty
        ? ', ${settings.learnerName}'
        : '';

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            // Header: greeting + hearts/streak + settings.
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$greeting$name 👋',
                          style: TextStyle(fontSize: 13, color: t.muted)),
                      const SizedBox(height: 2),
                      const DisplayText('Čeština', size: 26),
                    ],
                  ),
                ),
                PillChip(
                  label: '${g.hearts}',
                  bg: t.redSoft,
                  fg: t.red,
                  icon: Icons.favorite,
                ),
                const SizedBox(width: 8),
                PillChip(
                  label: '${g.currentStreak}',
                  bg: t.amberSoft,
                  fg: t.amber,
                  icon: Icons.local_fire_department,
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => context.push('/settings'),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: t.chipBg, shape: BoxShape.circle),
                    child: Icon(Icons.settings_outlined, size: 22, color: t.muted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _DailyGoalHero(
              dailyXp: g.dailyXp,
              dailyGoalXp: g.dailyGoalXp,
              totalXp: g.totalXp,
              streak: g.currentStreak,
            ),
            const SizedBox(height: 14),

            const _ContinueLearningCard(),
            const SizedBox(height: 14),

            // Daily learning tip — evidence-based strategies.
            const LearningTipCard(),
            const SizedBox(height: 14),

            // Quick actions row.
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.style_outlined,
                    tint: t.violetSoft,
                    fg: t.violet,
                    label: 'Review',
                    sub: '$dueCount due',
                    onTap: () => context.go('/review'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.chat_bubble_outline,
                    tint: t.priSoft,
                    fg: t.pri,
                    label: 'AI Chat',
                    sub: '6 scenarios',
                    onTap: () => context.go('/chat'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.mic_none,
                    tint: t.amberSoft,
                    fg: t.amber,
                    label: 'Speak',
                    sub: 'Pronounce ř',
                    onTap: () => context.push('/pronunciation/practice'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            _ShortcutRow(
              icon: Icons.assignment_outlined,
              tint: t.redSoft,
              fg: t.red,
              title: 'Mock exam',
              subtitle: 'Timed CCE practice · A1',
              onTap: () => _showExamLevelPicker(context),
            ),
            const SizedBox(height: 10),
            _ShortcutRow(
              icon: Icons.menu_book_outlined,
              tint: t.greenSoft,
              fg: t.green,
              title: 'Grammar reference',
              subtitle: 'All rules & examples',
              onTap: () => context.push('/grammar'),
            ),
            const SizedBox(height: 10),
            _ShortcutRow(
              icon: Icons.bar_chart,
              tint: t.priSoft,
              fg: t.pri,
              title: 'Your progress',
              subtitle: 'CEFR level, badges, streak stats',
              onTap: () => context.go('/stats'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet to choose the mock-exam level (A1 or A2).
void _showExamLevelPicker(BuildContext context) {
  final t = context.tokens;
  showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: DisplayText('Choose exam level', size: 20),
          ),
          for (final level in const [
            ('A1', 'CCE A1 — Beginner', 'a1'),
            ('A2', 'CCE A2 — Elementary', 'a2'),
          ])
            ListTile(
              leading: CircleAvatar(
                backgroundColor: t.priSoft,
                child: Text(level.$1,
                    style: TextStyle(color: t.priInk, fontWeight: FontWeight.w700)),
              ),
              title: Text(level.$2),
              subtitle: const Text('Reading, listening, writing, speaking'),
              onTap: () {
                Navigator.pop(sheetContext);
                context.push('/exam/${level.$3}');
              },
            ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}

/// Teal hero card showing daily XP goal, streak and total XP.
class _DailyGoalHero extends StatelessWidget {
  const _DailyGoalHero({
    required this.dailyXp,
    required this.dailyGoalXp,
    required this.totalXp,
    required this.streak,
  });

  final int dailyXp;
  final int dailyGoalXp;
  final int totalXp;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final progress = dailyGoalXp > 0 ? (dailyXp / dailyGoalXp).clamp(0.0, 1.0) : 0.0;
    const white = Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: t.priFill,
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned(
            right: -40,
            top: -30,
            child: Opacity(
              opacity: 0.14,
              child: _ConcentricRings(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DAILY GOAL',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.9,
                      color: white.withValues(alpha: 0.7),
                    )),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('$dailyXp',
                        style: const TextStyle(
                          fontFamily: AppFonts.display,
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          height: 1,
                          color: white,
                        )),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text('/ $dailyGoalXp XP today',
                          style: TextStyle(
                              fontSize: 15, color: white.withValues(alpha: 0.75))),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress == 0 ? 0.06 : progress,
                    minHeight: 8,
                    backgroundColor: white.withValues(alpha: 0.22),
                    valueColor: const AlwaysStoppedAnimation(white),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text('🔥 $streak day streak',
                        style: TextStyle(
                            fontSize: 13, color: white.withValues(alpha: 0.85))),
                    const SizedBox(width: 14),
                    Text('⭐ $totalXp total XP',
                        style: TextStyle(
                            fontSize: 13, color: white.withValues(alpha: 0.85))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConcentricRings extends StatelessWidget {
  const _ConcentricRings();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: CustomPaint(painter: _RingsPainter()),
    );
  }
}

class _RingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    for (final r in [86.0, 61.0, 36.0]) {
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Continue-learning card — next uncompleted lesson.
class _ContinueLearningCard extends ConsumerWidget {
  const _ContinueLearningCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final nextAsync = ref.watch(nextLessonProvider);

    return nextAsync.when(
      loading: () => SoftCard(
        child: Row(
          children: [
            const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(width: 14),
            Text('Loading…', style: TextStyle(color: t.muted)),
          ],
        ),
      ),
      error: (_, __) => _ShortcutRow(
        icon: Icons.school_outlined,
        tint: t.priSoft,
        fg: t.pri,
        title: 'Browse curriculum',
        subtitle: 'Start your first lesson',
        onTap: () => context.go('/curriculum'),
      ),
      data: (next) {
        if (next == null) {
          return _ShortcutRow(
            icon: Icons.check_circle_outline,
            tint: t.greenSoft,
            fg: t.green,
            title: 'All caught up!',
            subtitle: 'Every unlocked lesson is complete.',
            onTap: () => context.go('/curriculum'),
          );
        }
        return SoftCard(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          onTap: () => context.push('/lesson/${next.lesson.id}'),
          child: Row(
            children: [
              IconTile(icon: Icons.play_arrow_rounded, tint: t.priSoft, fg: t.pri,
                  size: 46, radius: 16, iconSize: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Continue learning',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700, color: t.ink)),
                    const SizedBox(height: 2),
                    Text('${next.unitTitle} · ${next.lesson.title}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: t.muted)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, size: 18, color: t.faint),
            ],
          ),
        );
      },
    );
  }
}

/// Compact vertical quick-action tile (icon + label + sub).
class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.tint,
    required this.fg,
    required this.label,
    required this.sub,
    required this.onTap,
  });

  final IconData icon;
  final Color tint;
  final Color fg;
  final String label;
  final String sub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return SoftCard(
      radius: 18,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      onTap: onTap,
      child: Column(
        children: [
          IconTile(icon: icon, tint: tint, fg: fg, size: 38, radius: 13, iconSize: 17),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(
                  fontSize: 12.5, fontWeight: FontWeight.w600, color: t.ink)),
          const SizedBox(height: 2),
          Text(sub, style: TextStyle(fontSize: 11, color: t.muted)),
        ],
      ),
    );
  }
}

/// Full-width shortcut row with tinted icon, title, subtitle, chevron.
class _ShortcutRow extends StatelessWidget {
  const _ShortcutRow({
    required this.icon,
    required this.tint,
    required this.fg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color tint;
  final Color fg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      onTap: onTap,
      child: Row(
        children: [
          IconTile(icon: icon, tint: tint, fg: fg, size: 40, radius: 14, iconSize: 17),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 14.5, fontWeight: FontWeight.w700, color: t.ink)),
                const SizedBox(height: 1),
                Text(subtitle, style: TextStyle(fontSize: 12.5, color: t.muted)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 16, color: t.faint),
        ],
      ),
    );
  }
}
