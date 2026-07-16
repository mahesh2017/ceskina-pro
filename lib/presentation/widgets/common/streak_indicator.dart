import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/gamification_providers.dart';

/// Streak indicator widget — shows current streak from persisted state.
class StreakIndicator extends ConsumerWidget {
  const StreakIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamification = ref.watch(gamificationProvider);
    final streak = gamification.currentStreak;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.local_fire_department,
          color: streak > 0 ? Colors.orange.shade600 : Colors.grey.shade400,
          size: 18,
        ),
        const SizedBox(width: 4),
        Text(
          '$streak',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: streak > 0 ? Colors.orange.shade700 : Colors.grey,
              ),
        ),
      ],
    );
  }
}