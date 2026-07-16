import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/gamification_providers.dart';

/// Hearts display widget — shows current hearts from persisted state.
class HeartsDisplay extends ConsumerWidget {
  const HeartsDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamification = ref.watch(gamificationProvider);
    final hearts = gamification.hearts;
    final maxHearts = gamification.maxHearts;
    final isFull = hearts >= maxHearts;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.favorite,
          color: hearts > 0 ? Colors.red : Colors.grey.shade400,
          size: 18,
        ),
        const SizedBox(width: 4),
        Text(
          '$hearts',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: hearts > 0 ? Colors.red : Colors.grey,
              ),
        ),
        if (!isFull) ...[
          const SizedBox(width: 4),
          Icon(
            Icons.access_time,
            size: 12,
            color: Colors.grey.shade400,
          ),
        ],
      ],
    );
  }
}