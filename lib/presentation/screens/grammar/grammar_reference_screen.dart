import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/database_providers.dart';
import '../../../data/database/database.dart' as db;
import '../../widgets/lesson/exercise_widget.dart' show TtsButton;

/// All seeded grammar rules, ordered by unit.
final allGrammarRulesProvider =
    FutureProvider<List<db.GrammarRule>>((ref) async {
  return ref.read(databaseProvider).curriculumDao.getAllGrammarRules();
});

/// Browsable, searchable grammar reference built from the seeded rules.
class GrammarReferenceScreen extends ConsumerStatefulWidget {
  /// When set, the rule with this id is expanded on open (e.g. opened from
  /// a lesson feedback card).
  final String? highlightRuleId;

  const GrammarReferenceScreen({super.key, this.highlightRuleId});

  @override
  ConsumerState<GrammarReferenceScreen> createState() =>
      _GrammarReferenceScreenState();
}

class _GrammarReferenceScreenState
    extends ConsumerState<GrammarReferenceScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final rulesAsync = ref.watch(allGrammarRulesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Grammar Reference')),
      body: rulesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Failed to load: $err')),
        data: (rules) {
          final q = _query.trim().toLowerCase();
          final filtered = q.isEmpty
              ? rules
              : rules
                  .where((r) =>
                      r.ruleName.toLowerCase().contains(q) ||
                      r.pattern.toLowerCase().contains(q) ||
                      r.explanation.toLowerCase().contains(q),)
                  .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search grammar rules',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              if (filtered.isEmpty)
                const Expanded(
                  child: Center(child: Text('No matching rules.')),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) => _RuleCard(
                      rule: filtered[i],
                      initiallyExpanded:
                          filtered[i].id == widget.highlightRuleId,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  final db.GrammarRule rule;
  final bool initiallyExpanded;

  const _RuleCard({required this.rule, this.initiallyExpanded = false});

  List<Map<String, dynamic>> _examples() {
    try {
      final decoded = jsonDecode(rule.examples);
      if (decoded is List) {
        return decoded.whereType<Map<String, dynamic>>().toList();
      }
    } catch (_) {
      // Malformed example JSON — just show none.
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final examples = _examples();
    return Card(
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        title: Text(rule.ruleName,
            style: const TextStyle(fontWeight: FontWeight.w600),),
        subtitle: Text(rule.pattern),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (rule.caseAffected != null) ...[
            Chip(
              label: Text('Case: ${rule.caseAffected}'),
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(height: 8),
          ],
          Text(rule.explanation,
              style: Theme.of(context).textTheme.bodyMedium,),
          if (examples.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Examples',
                style: Theme.of(context).textTheme.labelLarge,),
            const SizedBox(height: 4),
            ...examples.map((ex) {
              final cz = ex['cz'] as String? ?? '';
              final en = ex['en'] as String? ?? '';
              final note = ex['note'] as String?;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (cz.isNotEmpty) TtsButton(text: cz, size: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(TextSpan(children: [
                            TextSpan(
                              text: cz,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,),
                            ),
                            if (en.isNotEmpty)
                              TextSpan(
                                text: '  —  $en',
                                style: TextStyle(
                                    color: Colors.grey.shade600,),
                              ),
                          ]),),
                          if (note != null && note.isNotEmpty)
                            Text(note,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(fontStyle: FontStyle.italic),),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
