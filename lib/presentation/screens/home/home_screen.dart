import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/curriculum_providers.dart';
import '../../providers/gamification_providers.dart';
import '../../providers/review_providers.dart';
import '../../providers/database_providers.dart';
import '../../widgets/common/streak_indicator.dart';
import '../../widgets/common/hearts_display.dart';
import '../../widgets/common/xp_badge.dart';
import '../../../domain/entities/lesson.dart';

/// Home dashboard — streak, XP, daily goal ring, continue learning.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamification = ref.watch(gamificationProvider);
    final unitsAsync = ref.watch(allUnitsProvider);
    final unlockedIdsAsync = ref.watch(unlockedUnitIdsProvider);
    final dueCountAsync = ref.watch(dueCardCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Čeština Pro'),
        actions: [
          const HeartsDisplay(),
          const SizedBox(width: 8),
          const StreakIndicator(),
          const SizedBox(width: 8),
          const XpBadge(),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Daily goal ring + stats
          _DailyGoalCard(
            dailyXp: gamification.dailyXp,
            dailyGoalXp: gamification.dailyGoalXp,
            totalXp: gamification.totalXp,
            streak: gamification.currentStreak,
          ),
          const SizedBox(height: 16),

          // Continue learning — finds next uncompleted lesson
          _ContinueLearningCard(
            unitsAsync: unitsAsync,
            unlockedIdsAsync: unlockedIdsAsync,
            ref: ref,
          ),
          const SizedBox(height: 16),

          // Quick actions
          Row(
            children: [
              Expanded(
                child: _ReviewActionCard(
                  dueCount: dueCountAsync.value ?? 0,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.chat,
                  label: 'AI Chat',
                  onTap: () => context.go('/chat'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Exam prep
          Card(
            child: ListTile(
              leading: const Icon(Icons.assignment, size: 40),
              title: const Text('Mock Exam'),
              subtitle: const Text('Practice CCE-A1/A2 exam'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/exam/a1'),
            ),
          ),
          const SizedBox(height: 16),

          // Stats link
          Card(
            child: ListTile(
              leading: const Icon(Icons.bar_chart, size: 40),
              title: const Text('Your Progress'),
              subtitle: const Text('CEFR level, badges, streak stats'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/stats'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Daily goal card with a circular progress ring.
class _DailyGoalCard extends StatelessWidget {
  final int dailyXp;
  final int dailyGoalXp;
  final int totalXp;
  final int streak;

  const _DailyGoalCard({
    required this.dailyXp,
    required this.dailyGoalXp,
    required this.totalXp,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    final progress = dailyGoalXp > 0
        ? (dailyXp / dailyGoalXp).clamp(0.0, 1.0)
        : 0.0;
    final isGoalMet = dailyXp >= dailyGoalXp;
    final progressColor = isGoalMet ? Colors.green : Colors.blue;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Circular progress ring
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 6,
                    backgroundColor:
                        progressColor.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$dailyXp',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: progressColor,
                        ),
                      ),
                      Text(
                        '/ $dailyGoalXp',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            // Stats
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isGoalMet ? 'Daily goal complete! 🎉' : 'Daily Goal',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isGoalMet ? Colors.green : null,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  _StatChip(
                    icon: Icons.local_fire_department,
                    label: '$streak day streak',
                    color: streak > 0
                        ? Colors.orange.shade600
                        : Colors.grey,
                  ),
                  const SizedBox(height: 4),
                  _StatChip(
                    icon: Icons.star,
                    label: '$totalXp total XP',
                    color: Colors.amber.shade700,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Continue learning card — finds the next uncompleted lesson from unlocked units.
class _ContinueLearningCard extends ConsumerStatefulWidget {
  final AsyncValue<List<dynamic>> unitsAsync;
  final AsyncValue<Set<int>> unlockedIdsAsync;
  final WidgetRef ref;

  const _ContinueLearningCard({
    required this.unitsAsync,
    required this.unlockedIdsAsync,
    required this.ref,
  });

  @override
  ConsumerState<_ContinueLearningCard> createState() =>
      _ContinueLearningCardState();
}

class _ContinueLearningCardState
    extends ConsumerState<_ContinueLearningCard> {
  Lesson? _nextLesson;
  String? _nextLessonUnitTitle;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _findNextLesson();
  }

  Future<void> _findNextLesson() async {
    final units = widget.unitsAsync.maybeWhen(
      data: (u) => u,
      orElse: () => null,
    );
    if (units == null || units.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    final unlockedIds = widget.unlockedIdsAsync.maybeWhen(
      data: (ids) => ids,
      orElse: () => {units.first.id},
    );

    final progressRepo = ref.read(progressRepositoryProvider);
    final snapshot = await progressRepo.getSnapshot();
    final completedUnitIds = snapshot.unitScores.entries
        .where((e) => e.value >= 0.6)
        .map((e) => e.key)
        .toSet();

    // Find the first unlocked unit that isn't completed yet
    for (final unit in units) {
      if (!unlockedIds.contains(unit.id)) continue;
      if (completedUnitIds.contains(unit.id)) continue;

      // Found an unlocked, incomplete unit — get its lessons
      final lessons =
          await ref.read(unitLessonsProvider(unit.id).future);
      if (lessons.isNotEmpty) {
        if (mounted) {
          setState(() {
            _nextLesson = lessons.first;
            _nextLessonUnitTitle = unit.title;
            _loading = false;
          });
        }
        return;
      }
    }

    // All unlocked units completed — find first lesson from next locked unit
    for (final unit in units) {
      if (unlockedIds.contains(unit.id)) continue;
      final lessons =
          await ref.read(unitLessonsProvider(unit.id).future);
      if (lessons.isNotEmpty) {
        if (mounted) {
          setState(() {
            _nextLesson = lessons.first;
            _nextLessonUnitTitle = unit.title;
            _loading = false;
          });
        }
        return;
      }
    }

    // Fallback: first lesson of first unit
    for (final unit in units) {
      final lessons =
          await ref.read(unitLessonsProvider(unit.id).future);
      if (lessons.isNotEmpty) {
        if (mounted) {
          setState(() {
            _nextLesson = lessons.first;
            _nextLessonUnitTitle = unit.title;
            _loading = false;
          });
        }
        return;
      }
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Card(
        child: ListTile(
          leading: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          title: Text('Loading...'),
        ),
      );
    }

    final lesson = _nextLesson;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.play_circle, size: 48,
            color: Colors.blue),
        title: const Text('Continue Learning'),
        subtitle: Text(
          lesson != null
              ? '${_nextLessonUnitTitle ?? ''} → ${lesson.title}'
              : 'Start your Czech journey!',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: lesson != null
            ? () => context.go('/lesson/${lesson.id}')
            : () => context.go('/curriculum'),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 8),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}

/// Review action card with due card count badge.
class _ReviewActionCard extends StatelessWidget {
  final int dueCount;

  const _ReviewActionCard({required this.dueCount});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.go('/review'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.style, size: 32),
                  if (dueCount > 0)
                    Positioned(
                      right: -8,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$dueCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Review'),
            ],
          ),
        ),
      ),
    );
  }
}