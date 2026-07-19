import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/engines/gamification_engine.dart';
import '../../../domain/entities/gamification_state.dart';
import '../../providers/gamification_providers.dart';

/// XP badge widget — shows total XP and current league from persisted state.
class XpBadge extends ConsumerWidget {
  const XpBadge({super.key});

  static final _engine = GamificationEngine();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamification = ref.watch(gamificationProvider);
    final totalXp = gamification.totalXp;
    final league = _engine.getLeague(totalXp);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star, color: Colors.amber.shade600, size: 18),
        const SizedBox(width: 4),
        Text(
          '$totalXp',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.amber.shade700,
              ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: _leagueColor(league).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _leagueColor(league).withValues(alpha: 0.3)),
          ),
          child: Text(
            league.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: _leagueColor(league),
            ),
          ),
        ),
      ],
    );
  }

  Color _leagueColor(League league) {
    return switch (league) {
      League.bronze => const Color(0xFFCD7F32),
      League.silver => Colors.grey,
      League.gold => Colors.amber.shade700,
      League.platinum => Colors.cyan,
      League.diamond => Colors.blue,
    };
  }
}