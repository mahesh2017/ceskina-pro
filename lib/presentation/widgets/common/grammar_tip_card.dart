import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Grammar tip card shown after answering — displays explanation on wrong answers,
/// positive feedback on correct ones.
class GrammarTipCard extends StatelessWidget {
  final bool isCorrect;
  final String? explanation;
  final String? correctAnswer;

  /// When set, shows a link into the grammar reference for this rule.
  final String? grammarRuleId;

  const GrammarTipCard({
    super.key,
    required this.isCorrect,
    this.explanation,
    this.correctAnswer,
    this.grammarRuleId,
  });

  @override
  Widget build(BuildContext context) {
    if (isCorrect && explanation == null) {
      // Just positive feedback
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Správně! Correct!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                  if (explanation != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        explanation!,
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Wrong answer — show explanation
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect ? Colors.green.shade200 : Colors.orange.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.lightbulb,
                color: isCorrect ? Colors.green : Colors.orange.shade700,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isCorrect ? 'Správně! Correct!' : 'Not quite right',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isCorrect
                        ? Colors.green.shade800
                        : Colors.orange.shade800,
                  ),
                ),
              ),
            ],
          ),
          if (correctAnswer != null && !isCorrect) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Correct answer: $correctAnswer',
                style: TextStyle(
                  color: Colors.green.shade900,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          if (explanation != null) ...[
            const SizedBox(height: 12),
            Text(
              '💡 Grammar tip:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isCorrect
                    ? Colors.green.shade800
                    : Colors.orange.shade800,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              explanation!,
              style: TextStyle(
                color: isCorrect
                    ? Colors.green.shade700
                    : Colors.orange.shade700,
                fontSize: 14,
              ),
            ),
          ],
          if (grammarRuleId != null) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () =>
                    context.push('/grammar?rule=$grammarRuleId'),
                icon: const Icon(Icons.menu_book, size: 18),
                label: const Text('View grammar rule'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}