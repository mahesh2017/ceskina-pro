import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/gamification_providers.dart';
import '../../providers/curriculum_providers.dart';
import '../../providers/database_providers.dart';
import '../../../domain/engines/curriculum_tracker.dart';
import '../../../domain/entities/gamification_state.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/unit.dart';

/// Stats / progress screen — CEFR level, mastery breakdown, badges, streak.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamification = ref.watch(gamificationProvider);
    final dataAsync = ref.watch(_statsDataProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Your Progress')),
      body: dataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Failed to load: $err')),
        data: (data) {
          final snapshot = data.snapshot;
          final tracker = CurriculumProgressTracker();

          final a1UnitIds =
              data.units.where((u) => u.phase == Phase.a1).map((u) => u.id).toSet();
          final a2UnitIds =
              data.units.where((u) => u.phase == Phase.a2).map((u) => u.id).toSet();

          final a1Completion = tracker.phaseCompletion(
            unitScores: snapshot.unitScores,
            phaseUnitIds: a1UnitIds,
          );
          final a2Completion = tracker.phaseCompletion(
            unitScores: snapshot.unitScores,
            phaseUnitIds: a2UnitIds,
          );
          final cefrLevel = tracker.estimateLevel(
            a1Completion: a1Completion,
            a2Completion: a2Completion,
            examsPassed: snapshot.examsPassed,
          );

          // Show mastery rows only for units the learner has started.
          final startedA1 = a1UnitIds
              .where(snapshot.unitScores.containsKey)
              .toList()
            ..sort();
          final startedA2 = a2UnitIds
              .where(snapshot.unitScores.containsKey)
              .toList()
            ..sort();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // CEFR Level card
              _CefrLevelCard(level: cefrLevel),
              const SizedBox(height: 16),

              // Completion progress bars
              _CompletionCard(
                a1Completion: a1Completion,
                a2Completion: a2Completion,
              ),
              const SizedBox(height: 16),

              // Streak & XP stats
              _StatsGrid(gamification: gamification),
              const SizedBox(height: 16),

              // Unit mastery breakdown
              _UnitMasteryCard(
                unitScores: snapshot.unitScores,
                a1Units: startedA1,
                a2Units: startedA2,
              ),
              const SizedBox(height: 16),

              // Badges
              _BadgesCard(earnedBadges: gamification.earnedBadges),
            ],
          );
        },
      ),
    );
  }
}

class _StatsData {
  final ProgressSnapshot snapshot;
  final List<Unit> units;
  const _StatsData({required this.snapshot, required this.units});
}

/// Progress snapshot + unit catalogue for the stats screen.
/// autoDispose so re-opening the screen always shows fresh progress.
final _statsDataProvider = FutureProvider.autoDispose<_StatsData>((ref) async {
  final repo = ref.read(progressRepositoryProvider);
  final snapshot = await repo.getSnapshot();
  final units = await ref.watch(allUnitsProvider.future);
  return _StatsData(snapshot: snapshot, units: units);
});

/// CEFR level card with circular indicator.
class _CefrLevelCard extends StatelessWidget {
  final CEFRLevel level;

  const _CefrLevelCard({required this.level});

  @override
  Widget build(BuildContext context) {
    final color = switch (level) {
      CEFRLevel.preA1 => Colors.grey,
      CEFRLevel.a1 => Colors.blue,
      CEFRLevel.a2 => Colors.green,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.15),
                border: Border.all(color: color, width: 3),
              ),
              child: Center(
                child: Text(
                  level.label,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your CEFR Level',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _levelDescription(level),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _levelDescription(CEFRLevel level) {
    return switch (level) {
      CEFRLevel.preA1 => 'Just getting started — keep practicing!',
      CEFRLevel.a1 => 'Beginner — can handle basic everyday expressions.',
      CEFRLevel.a2 => 'Elementary — can communicate in simple tasks.',
    };
  }
}

/// A1/A2 completion progress bars.
class _CompletionCard extends StatelessWidget {
  final double a1Completion;
  final double a2Completion;

  const _CompletionCard({
    required this.a1Completion,
    required this.a2Completion,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Course Completion',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _ProgressRow(
              label: 'A1 — Beginner',
              progress: a1Completion,
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _ProgressRow(
              label: 'A2 — Elementary',
              progress: a2Completion,
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final double progress;
  final Color color;

  const _ProgressRow({
    required this.label,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            Text(
              '$percent%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

/// Stats grid — streak, XP, hearts, lessons.
class _StatsGrid extends StatelessWidget {
  final GamificationState gamification;

  const _StatsGrid({required this.gamification});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: [
        _StatTile(
          icon: Icons.local_fire_department,
          value: '${gamification.currentStreak}',
          label: 'Day streak',
          color: Colors.orange,
        ),
        _StatTile(
          icon: Icons.star,
          value: '${gamification.totalXp}',
          label: 'Total XP',
          color: Colors.amber,
        ),
        _StatTile(
          icon: Icons.emoji_events,
          value: '${gamification.longestStreak}',
          label: 'Longest streak',
          color: Colors.deepOrange,
        ),
        _StatTile(
          icon: Icons.favorite,
          value: '${gamification.hearts}/${gamification.maxHearts}',
          label: 'Hearts',
          color: Colors.red,
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Unit mastery breakdown.
class _UnitMasteryCard extends StatelessWidget {
  final Map<int, double> unitScores;
  final List<int> a1Units;
  final List<int> a2Units;

  const _UnitMasteryCard({
    required this.unitScores,
    required this.a1Units,
    required this.a2Units,
  });

  @override
  Widget build(BuildContext context) {
    if (unitScores.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'No lessons completed yet. Start learning to see your progress!',
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Unit Mastery',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (a1Units.isNotEmpty) ...[
              Text('A1 Units', style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade700,
                fontWeight: FontWeight.bold,
              ),),
              const SizedBox(height: 6),
              ...a1Units.map((id) => _UnitScoreRow(
                    unitId: id,
                    score: unitScores[id] ?? 0,
                  ),),
            ],
            if (a2Units.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('A2 Units', style: TextStyle(
                fontSize: 12,
                color: Colors.green.shade700,
                fontWeight: FontWeight.bold,
              ),),
              const SizedBox(height: 6),
              ...a2Units.map((id) => _UnitScoreRow(
                    unitId: id,
                    score: unitScores[id] ?? 0,
                  ),),
            ],
          ],
        ),
      ),
    );
  }
}

class _UnitScoreRow extends StatelessWidget {
  final int unitId;
  final double score;

  const _UnitScoreRow({required this.unitId, required this.score});

  @override
  Widget build(BuildContext context) {
    final percent = (score * 100).round();
    final color = score >= 0.8
        ? Colors.green
        : score >= 0.6
            ? Colors.orange
            : Colors.red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text('Unit $unitId'),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: score,
                minHeight: 6,
                backgroundColor: color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 36,
            child: Text(
              '$percent%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

/// Badges display.
class _BadgesCard extends StatelessWidget {
  final Set<String> earnedBadges;

  const _BadgesCard({required this.earnedBadges});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Badges (${earnedBadges.length}/${Badge.all.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: Badge.all.map((badge) {
                final isEarned = earnedBadges.contains(badge.id);
                return _BadgeTile(badge: badge, isEarned: isEarned);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final Badge badge;
  final bool isEarned;

  const _BadgeTile({required this.badge, required this.isEarned});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '${badge.name}: ${badge.description}',
      child: Opacity(
        opacity: isEarned ? 1.0 : 0.3,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isEarned
                    ? Colors.amber.withValues(alpha: 0.15)
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                border: Border.all(
                  color: isEarned
                      ? Colors.amber
                      : Theme.of(context).colorScheme.outlineVariant,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  badge.icon,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              badge.name,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isEarned ? FontWeight.bold : FontWeight.normal,
                color: isEarned ? Colors.amber.shade800 : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}