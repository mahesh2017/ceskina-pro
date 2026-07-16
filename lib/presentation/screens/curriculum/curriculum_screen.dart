import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/curriculum_providers.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/unit.dart';
import '../../../domain/entities/lesson.dart';

/// Curriculum path — visual map of all units (A1 + A2) loaded from DB.
class CurriculumScreen extends ConsumerWidget {
  const CurriculumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitsAsync = ref.watch(allUnitsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Curriculum')),
      body: unitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Failed to load curriculum: $err',
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(allUnitsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (units) {
          // Split into A1 and A2
          final a1Units =
              units.where((u) => u.phase == Phase.a1).toList();
          final a2Units =
              units.where((u) => u.phase == Phase.a2).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // A1 section
              _PhaseHeader(
                title: 'Phase 1: A1',
                subtitle: 'Beginner — ${a1Units.length} units',
              ),
              const SizedBox(height: 8),
              ...a1Units.asMap().entries.map((entry) {
                final idx = entry.key;
                final unit = entry.value;
                // First unit always unlocked, rest sequential
                final isUnlocked = idx == 0;
                return _UnitCard(
                  unit: unit,
                  isUnlocked: isUnlocked,
                  ref: ref,
                );
              }),

              const SizedBox(height: 24),

              // A2 section
              _PhaseHeader(
                title: 'Phase 2: A2',
                subtitle: 'Elementary — ${a2Units.length} units',
              ),
              const SizedBox(height: 8),
              ...a2Units.asMap().entries.map((entry) {
                final unit = entry.value;
                // A2 units locked until A1 complete (simplified: all locked for now)
                return _UnitCard(
                  unit: unit,
                  isUnlocked: false,
                  ref: ref,
                );
              }),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}

class _PhaseHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _PhaseHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(width: 8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
        ),
      ],
    );
  }
}

class _UnitCard extends ConsumerWidget {
  final Unit unit;
  final bool isUnlocked;
  final WidgetRef ref;

  const _UnitCard({
    required this.unit,
    required this.isUnlocked,
    required this.ref,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(unitLessonsProvider(unit.id));

    return Card(
      child: ExpansionTile(
        leading: Icon(
          isUnlocked ? Icons.play_circle : Icons.lock,
          color: isUnlocked
              ? Theme.of(context).colorScheme.primary
              : Colors.grey,
        ),
        title: Text('Unit ${unit.id}: ${unit.title}'),
        subtitle: Text(unit.description, maxLines: 2, overflow: TextOverflow.ellipsis),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        children: lessonsAsync.when(
          loading: () => const [
            Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
          error: (_, __) => const [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text('No lessons available yet'),
            ),
          ],
          data: (lessons) {
            if (lessons.isEmpty) {
              return const [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No lessons available yet'),
                ),
              ];
            }
            return lessons.map((lesson) => _LessonTile(
                  lesson: lesson,
                  isUnlocked: isUnlocked,
                )).toList();
          },
        ),
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  final Lesson lesson;
  final bool isUnlocked;

  const _LessonTile({required this.lesson, required this.isUnlocked});

  @override
  Widget build(BuildContext context) {
    final lessonTypeIcon = switch (lesson.lessonType) {
      LessonType.introduction => Icons.info_outline,
      LessonType.practice => Icons.fitness_center,
      LessonType.application => Icons.local_florist,
      LessonType.review => Icons.replay,
    };

    return ListTile(
      leading: Icon(
        lessonTypeIcon,
        color: isUnlocked ? Theme.of(context).colorScheme.primary : Colors.grey,
        size: 20,
      ),
      title: Text(
        lesson.title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isUnlocked ? null : Colors.grey,
        ),
      ),
      subtitle: Text(
        '${lesson.durationMinutes} min • ${lesson.description}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12),
      ),
      trailing: isUnlocked
          ? const Icon(Icons.chevron_right)
          : const Icon(Icons.lock, size: 16),
      onTap: isUnlocked
          ? () => context.go('/lesson/${lesson.id}')
          : null,
    );
  }
}