/// Classifies exercises only when their type or curriculum metadata explicitly
/// supports a concept-level inference.
class ConceptClassifier {
  const ConceptClassifier();

  Map<String, String> classify({
    required String exerciseType,
    String? ruleName,
    String? rulePattern,
    String? ruleExplanation,
    String? caseAffected,
    List<String> conceptTags = const [],
    String? communicativeFunction,
  }) {
    final concepts = <String, String>{};
    final text =
        [
          ruleName,
          rulePattern,
          ruleExplanation,
        ].whereType<String>().join(' ').toLowerCase();

    if (exerciseType == 'word_order') {
      concepts['word_order'] = 'Word order';
    }

    final grammaticalCase = caseAffected?.trim().toLowerCase();
    if (grammaticalCase != null && grammaticalCase.isNotEmpty) {
      concepts['case:$grammaticalCase'] = '${_titleCase(grammaticalCase)} case';
    }
    if (_containsAny(text, const [
      'gender',
      'masculine',
      'feminine',
      'neuter',
    ])) {
      concepts['gender'] = 'Grammatical gender';
    }
    if (_containsAny(text, const ['aspect', 'perfective', 'imperfective'])) {
      concepts['verb_aspect'] = 'Verb aspect';
    }
    if (_containsAny(text, const ['formal', 'informal', 'register'])) {
      concepts['register'] = 'Formal and informal register';
    }
    if (_containsAny(text, const [
      'long vs short vowel',
      'long and short vowel',
      'vowel length',
      'long vowels',
      'short vowels',
    ])) {
      concepts['vowel_length'] = 'Vowel length';
    }
    for (final tag in conceptTags.map((tag) => tag.trim().toLowerCase())) {
      switch (tag) {
        case 'gender':
          concepts['gender'] = 'Grammatical gender';
        case 'verb_aspect' || 'aspect':
          concepts['verb_aspect'] = 'Verb aspect';
        case 'word_order':
          concepts['word_order'] = 'Word order';
        case 'vowel_length':
          concepts['vowel_length'] = 'Vowel length';
        case 'register':
          concepts['register'] = 'Formal and informal register';
      }
    }
    final function = communicativeFunction?.trim();
    if (function != null && function.isNotEmpty) {
      concepts['communicative_function:${_slug(function)}'] =
          'Communicative function: $function';
    }

    return concepts;
  }

  bool _containsAny(String text, List<String> terms) =>
      terms.any(text.contains);

  String _titleCase(String value) =>
      value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';

  String _slug(String value) => value
      .toLowerCase()
      .replaceAll(RegExp('[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
}
