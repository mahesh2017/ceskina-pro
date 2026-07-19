import 'package:flutter/material.dart';

/// Shared 0–1 score → colour/label mapping so pronunciation, exercises, and
/// stats all grade on the same scale instead of each re-deriving thresholds.
class ScoreColors {
  ScoreColors._();

  static const goodThreshold = 0.8;
  static const okThreshold = 0.65;

  static Color of(double score) {
    if (score >= goodThreshold) return Colors.green;
    if (score >= okThreshold) return Colors.orange;
    return Colors.red;
  }

  /// Bilingual (Czech/English) encouragement label for a score.
  static String label(double score) {
    if (score >= goodThreshold) return 'Výborně! Excellent!';
    if (score >= okThreshold) return 'Dobře. Good — keep practicing.';
    return 'Zkuste znovu. Try again.';
  }
}
