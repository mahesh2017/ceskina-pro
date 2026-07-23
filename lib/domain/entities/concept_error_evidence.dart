/// Observable first-pass errors for a curriculum concept.
///
/// This is diagnostic practice evidence, not a claim about proficiency.
class ConceptErrorEvidence {
  final String conceptKey;
  final String label;
  final int initialErrors;
  final int repairedErrors;
  final DateTime latestErrorAt;

  const ConceptErrorEvidence({
    required this.conceptKey,
    required this.label,
    required this.initialErrors,
    required this.repairedErrors,
    required this.latestErrorAt,
  });

  int get unresolvedErrors => initialErrors - repairedErrors;
}
