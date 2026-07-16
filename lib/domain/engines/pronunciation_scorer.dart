import '../entities/pronunciation_result.dart';
import '../../core/utils/text_normalizer.dart';
import '../../core/utils/phoneme_mapper.dart';

/// Custom pronunciation scoring engine for Czech.
///
/// Azure Pronunciation Assessment doesn't support Czech,
/// so we use STT transcription + text comparison + phonetic scoring.
class PronunciationScorer {
  final PhonemeMapper _phonemeMapper = PhonemeMapper();

  /// Score user's pronunciation against expected text.
  ///
  /// Pipeline:
  /// 1. Normalize both texts (lowercase, strip punctuation)
  /// 2. Word-level alignment (Levenshtein distance)
  /// 3. Phonetic comparison for Czech-specific sounds
  /// 4. Return per-word and overall scores
  PronunciationResult score({
    required String expectedText,
    required String actualTranscription,
  }) {
    final normalizedExpected = TextNormalizer.normalize(expectedText);
    final normalizedActual = TextNormalizer.normalize(actualTranscription);

    // Word-level alignment
    final wordResults = _alignWords(normalizedExpected, normalizedActual);

    // Phonetic scoring for Czech problem sounds
    final problemSounds = _scorePhonemes(wordResults);

    // Overall accuracy
    final accuracy = _calculateAccuracy(wordResults);

    final feedback = _generateFeedback(problemSounds);

    return PronunciationResult(
      overallScore: accuracy,
      wordScores: wordResults,
      problemSounds: problemSounds,
      feedback: feedback,
    );
  }

  /// Align words between expected and actual using simple matching.
  List<WordScore> _alignWords(String expected, String actual) {
    final expectedWords = expected.split(' ').where((w) => w.isNotEmpty).toList();
    final actualWords = actual.split(' ').where((w) => w.isNotEmpty).toList();

    final results = <WordScore>[];

    for (var i = 0; i < expectedWords.length; i++) {
      if (i < actualWords.length) {
        final isMatch = expectedWords[i].toLowerCase() == actualWords[i].toLowerCase();
        final similarity = _wordSimilarity(expectedWords[i], actualWords[i]);
        results.add(WordScore(
          word: expectedWords[i],
          isCorrect: isMatch,
          score: similarity,
        ));
      } else {
        results.add(WordScore(word: expectedWords[i], isCorrect: false, score: 0.0));
      }
    }

    return results;
  }

  /// Calculate word similarity using character-level comparison.
  double _wordSimilarity(String a, String b) {
    if (a.toLowerCase() == b.toLowerCase()) return 1.0;
    final distance = _levenshtein(a.toLowerCase(), b.toLowerCase());
    final maxLen = a.length > b.length ? a.length : b.length;
    if (maxLen == 0) return 1.0;
    return 1.0 - (distance / maxLen);
  }

  /// Levenshtein distance between two strings.
  int _levenshtein(String s1, String s2) {
    final matrix = List.generate(
      s1.length + 1,
      (i) => List.generate(s2.length + 1, (j) => 0),
    );

    for (var i = 0; i <= s1.length; i++) matrix[i][0] = i;
    for (var j = 0; j <= s2.length; j++) matrix[0][j] = j;

    for (var i = 1; i <= s1.length; i++) {
      for (var j = 1; j <= s2.length; j++) {
        final cost = s1[i - 1].toLowerCase() == s2[j - 1].toLowerCase() ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[s1.length][s2.length];
  }

  /// Score Czech-specific phonemes.
  List<ProblemSound> _scorePhonemes(List<WordScore> wordScores) {
    final problems = <ProblemSound>[];

    for (final word in wordScores) {
      if (word.score < 0.7) {
        // Check for Czech-specific problem sounds in the expected word
        final phonemes = _phonemeMapper.getProblemPhonemes(word.word);
        for (final phoneme in phonemes) {
          problems.add(ProblemSound(
            phoneme: phoneme,
            word: word.word,
            score: word.score,
          ));
        }
      }
    }

    return problems;
  }

  /// Calculate overall accuracy from word scores.
  double _calculateAccuracy(List<WordScore> wordScores) {
    if (wordScores.isEmpty) return 0.0;
    final totalScore = wordScores.fold<double>(0.0, (sum, w) => sum + w.score);
    return totalScore / wordScores.length;
  }

  /// Generate feedback based on problem sounds.
  String _generateFeedback(List<ProblemSound> problems) {
    if (problems.isEmpty) return 'Skvělé! Výborná výslovnost.';

    return problems.map((p) {
      return switch (p.phoneme) {
        'ř' => 'Practice the "ř" sound — roll the tongue slightly further back.',
        'ě' => 'The "ě" softens the consonant before it (dě → d+ye).',
        'long_vowel' => 'Czech distinguishes short and long vowels. Lengthen the vowel.',
        _ => 'Check pronunciation of "${p.phoneme}" in "${p.word}".',
      };
    }).join('\n');
  }
}