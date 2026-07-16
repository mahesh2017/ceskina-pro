import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/curriculum_providers.dart';
import '../../providers/gamification_providers.dart';
import '../../providers/review_providers.dart';
import '../../widgets/common/streak_indicator.dart';
import '../../widgets/common/hearts_display.dart';
import '../../widgets/common/xp_badge.dart';

/// Home dashboard — streak, XP, daily goal, continue learning.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamification = ref.watch(gamificationProvider);
    final unitsAsync = ref.watch(allUnitsProvider);
    final firstLessonAsync = unitsAsync.maybeWhen(
      data: (units) {
        if (units.isEmpty) return null;
        return ref.watch(unitLessonsProvider(units.first.id).future).then(
              (lessons) => lessons.isNotEmpty ? lessons.first : null,
            );
      },
      orElse: () => null,
    );

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
          // Daily goal card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Goal',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: gamification.dailyGoalMet
                        ? 1.0
                        : gamification.dailyXp / gamification.dailyGoalXp,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${gamification.dailyXp} / ${gamification.dailyGoalXp} XP',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Continue learning — first available lesson
          FutureBuilder(
            future: firstLessonAsync,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
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

              final lesson = snapshot.data;
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.play_circle, size: 48),
                  title: const Text('Continue Learning'),
                  subtitle: Text(lesson != null
                      ? lesson.title
                      : 'Start your Czech journey!'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: lesson != null
                      ? () => context.go('/lesson/${lesson.id}')
                      : () => context.go('/curriculum'),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Quick actions
          Row(
            children: [
              Expanded(
                child: _ReviewActionCard(ref: ref),
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
class _ReviewActionCard extends ConsumerWidget {
  final WidgetRef ref;

  const _ReviewActionCard({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueCountAsync = ref.watch(dueCardCountProvider);
    final dueCount = dueCountAsync.value ?? 0;

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
                        decoration: BoxDecoration(
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