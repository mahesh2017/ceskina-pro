/// Result of pronunciation assessment.
class PronunciationResult {
  final double overallScore; // 0.0 - 1.0
  final List<WordScore> wordScores;
  final List<ProblemSound> problemSounds;
  final String feedback;

  const PronunciationResult({
    required this.overallScore,
    required this.wordScores,
    required this.problemSounds,
    required this.feedback,
  });

  bool get isPassing => overallScore >= 0.65;
}

/// Per-word pronunciation score.
class WordScore {
  final String word;
  final bool isCorrect;
  final double score; // 0.0 - 1.0

  const WordScore({required this.word, required this.isCorrect, required this.score});
}

/// A sound the learner struggled with.
class ProblemSound {
  final String phoneme;
  final String word;
  final double score; // 0.0 - 1.0

  const ProblemSound({required this.phoneme, required this.word, required this.score});
}