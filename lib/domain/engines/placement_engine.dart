import '../entities/learning_evidence.dart';

class DiagnosticItem {
  final String id;
  final LearningSkill skill;
  final double difficulty;
  final int unitCeiling;
  final bool optional;

  const DiagnosticItem({
    required this.id,
    required this.skill,
    required this.difficulty,
    required this.unitCeiling,
    this.optional = false,
  });
}

class DiagnosticObservation {
  final DiagnosticItem item;
  final bool correct;
  final bool independent;

  const DiagnosticObservation({
    required this.item,
    required this.correct,
    required this.independent,
  });
}

class PlacementResult {
  final Map<LearningSkill, double> estimates;
  final int provisionalUnit;
  final int sampleSize;

  const PlacementResult({
    required this.estimates,
    required this.provisionalUnit,
    required this.sampleSize,
  });
}

/// Short multiskill diagnostic. Estimates are deliberately provisional and
/// can be revised by delayed transfer evidence or a learner override.
class PlacementEngine {
  static const requiredSkills = {
    LearningSkill.reading,
    LearningSkill.listening,
    LearningSkill.writing,
  };
  static const minItems = 8;
  static const maxItems = 12;

  const PlacementEngine();

  DiagnosticItem? nextItem({
    required List<DiagnosticItem> bank,
    required List<DiagnosticObservation> observations,
    bool includeSpeaking = false,
  }) {
    if (isComplete(observations, includeSpeaking: includeSpeaking)) return null;
    final used = observations.map((value) => value.item.id).toSet();
    final allowedSkills = {
      ...requiredSkills,
      if (includeSpeaking) LearningSkill.speaking,
    };
    final candidates =
        bank
            .where(
              (item) =>
                  !used.contains(item.id) &&
                  allowedSkills.contains(item.skill) &&
                  (includeSpeaking || !item.optional),
            )
            .toList();
    if (candidates.isEmpty) return null;

    final counts = <LearningSkill, int>{
      for (final skill in allowedSkills)
        skill: observations.where((value) => value.item.skill == skill).length,
    };
    final targetSkill =
        counts.entries.reduce((a, b) => a.value <= b.value ? a : b).key;
    final estimate = estimateSkill(observations, targetSkill);
    final sameSkill =
        candidates.where((item) => item.skill == targetSkill).toList();
    final pool = sameSkill.isEmpty ? candidates : sameSkill;
    pool.sort(
      (a, b) => (a.difficulty - estimate).abs().compareTo(
        (b.difficulty - estimate).abs(),
      ),
    );
    return pool.first;
  }

  bool isComplete(
    List<DiagnosticObservation> observations, {
    bool includeSpeaking = false,
  }) {
    if (observations.length >= maxItems) return true;
    if (observations.length < minItems) return false;
    final sampled = observations.map((value) => value.item.skill).toSet();
    return sampled.containsAll(requiredSkills) &&
        (!includeSpeaking || sampled.contains(LearningSkill.speaking));
  }

  double estimateSkill(
    List<DiagnosticObservation> observations,
    LearningSkill skill,
  ) {
    final samples =
        observations.where((value) => value.item.skill == skill).toList();
    if (samples.isEmpty) return 0.25;
    var total = 0.0;
    for (final sample in samples) {
      final outcome = sample.correct ? 0.25 : -0.25;
      final supportPenalty = sample.independent ? 0.0 : 0.15;
      total += (sample.item.difficulty + outcome - supportPenalty).clamp(0, 1);
    }
    return total / samples.length;
  }

  PlacementResult result(
    List<DiagnosticObservation> observations, {
    int? learnerOverrideUnit,
    Iterable<LearningEvidence> earlyEvidence = const [],
  }) {
    final estimates = <LearningSkill, double>{
      for (final skill in requiredSkills)
        skill: estimateSkill(observations, skill),
    };
    for (final evidence in earlyEvidence.where(
      (value) => value.isDelayedTransfer,
    )) {
      final current = estimates[evidence.skill];
      if (current == null) continue;
      final adjustment =
          evidence.correct && evidence.independent
              ? 0.05
              : evidence.correct
              ? -0.03
              : -0.12;
      estimates[evidence.skill] = (current + adjustment).clamp(0, 1);
    }
    final conservative = estimates.values.reduce((a, b) => a < b ? a : b);
    final inferredUnit = switch (conservative) {
      < 0.35 => 1,
      < 0.5 => 6,
      < 0.65 => 12,
      < 0.78 => 18,
      _ => 24,
    };
    return PlacementResult(
      estimates: Map.unmodifiable(estimates),
      provisionalUnit: (learnerOverrideUnit ?? inferredUnit).clamp(1, 31),
      sampleSize: observations.length,
    );
  }
}
