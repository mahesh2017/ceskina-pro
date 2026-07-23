/// Transparent aggregate of observable practice responses.
///
/// Confidence describes evidence depth (sample size), not language mastery.
class PracticeEvidence {
  final String componentKey;
  final String label;
  final int exposures;
  final int initialAttempts;
  final int initialCorrect;
  final int repairAttempts;
  final int repairCorrect;
  final DateTime? latestAt;

  const PracticeEvidence({
    required this.componentKey,
    required this.label,
    required this.exposures,
    required this.initialAttempts,
    required this.initialCorrect,
    required this.repairAttempts,
    required this.repairCorrect,
    this.latestAt,
  });

  double? get firstPassAccuracy =>
      initialAttempts == 0 ? null : initialCorrect / initialAttempts;

  double? get repairAccuracy =>
      repairAttempts == 0 ? null : repairCorrect / repairAttempts;

  EvidenceDepth get evidenceDepth => switch (initialAttempts) {
    0 => EvidenceDepth.none,
    < 3 => EvidenceDepth.limited,
    < 8 => EvidenceDepth.growing,
    _ => EvidenceDepth.substantial,
  };
}

enum EvidenceDepth {
  none('No scored evidence'),
  limited('Limited evidence'),
  growing('Growing evidence'),
  substantial('Substantial evidence');

  const EvidenceDepth(this.label);
  final String label;
}
