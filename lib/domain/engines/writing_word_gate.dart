/// Deterministic minimum-length gate for productive writing tasks.
///
/// The permanent-residence A2 exam applies a non-negotiable rule to the e-mail
/// task: a response below its declared minimum word count scores **0**,
/// regardless of content quality ("Pozor! Když nenapíšete minimálně N slov,
/// dostanete 0 bodů."). This is an official, deterministic rule — it must be
/// enforced before (and independently of) any AI evaluation, so an unavailable
/// evaluator can never turn an under-length answer into a pass, and a too-short
/// answer can never be scored on content.
///
/// The threshold itself is task data (`min_words`); this engine only enforces
/// whatever a task declares. Choosing the correct per-task value is content
/// work owned by the exam blueprint / specialist review.
class WritingWordGate {
  const WritingWordGate._();

  /// Counts words as whitespace-separated tokens that contain at least one
  /// letter or digit, so stray punctuation ("-", "—", ".") is not a word.
  static int countWords(String text) {
    final tokens = text.trim().split(RegExp(r'\s+'));
    return tokens
        .where((t) => RegExp(r'[\p{L}\p{N}]', unicode: true).hasMatch(t))
        .length;
  }

  /// True when [text] fails the task's [minWords] requirement. A null or
  /// non-positive minimum means the task has no length gate.
  static bool belowMinimum(String text, int? minWords) {
    if (minWords == null || minWords <= 0) return false;
    return countWords(text) < minWords;
  }
}
