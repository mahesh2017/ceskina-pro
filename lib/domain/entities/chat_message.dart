/// A chat message in an AI conversation.
class ChatMessage {
  final String id;
  final String conversationId;
  final MessageRole role;
  final String content;
  final String? translation;
  final List<Correction>? corrections;
  final List<NewVocabulary>? newVocabulary;
  final String? audioPath;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    this.translation,
    this.corrections,
    this.newVocabulary,
    this.audioPath,
    required this.createdAt,
  });

  factory ChatMessage.user(String text, {String? conversationId}) {
    return ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId ?? '',
      role: MessageRole.user,
      content: text,
      createdAt: DateTime.now(),
    );
  }

  factory ChatMessage.tutor({
    required String text,
    String? translation,
    List<Correction>? corrections,
    List<NewVocabulary>? newVocabulary,
    String? audioPath,
    String? conversationId,
  }) {
    return ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_tutor',
      conversationId: conversationId ?? '',
      role: MessageRole.tutor,
      content: text,
      translation: translation,
      corrections: corrections,
      newVocabulary: newVocabulary,
      audioPath: audioPath,
      createdAt: DateTime.now(),
    );
  }
}

enum MessageRole { user, tutor }

/// A grammar correction from the AI tutor.
class Correction {
  final CorrectionType type;
  final String userSaid;
  final String correct;
  final String rule;
  final Severity severity;

  const Correction({
    required this.type,
    required this.userSaid,
    required this.correct,
    required this.rule,
    this.severity = Severity.error,
  });

  factory Correction.fromJson(Map<String, dynamic> json) {
    return Correction(
      type: CorrectionType.values.byName(json['type'] as String),
      userSaid: json['user_said'] as String,
      correct: json['correct'] as String,
      rule: json['rule'] as String,
      severity: Severity.values.byName(json['severity'] as String? ?? 'error'),
    );
  }
}

enum CorrectionType {
  case_,
  verbConjugation,
  aspect,
  wordOrder,
  genderAgreement,
  spelling,
  vowelLength,
  preposition,
}

enum Severity { error, minor, stylistic }

/// New vocabulary introduced by the tutor.
class NewVocabulary {
  final String cz;
  final String en;
  final String? ipa;

  const NewVocabulary({required this.cz, required this.en, this.ipa});

  factory NewVocabulary.fromJson(Map<String, dynamic> json) {
    return NewVocabulary(
      cz: json['cz'] as String,
      en: json['en'] as String,
      ipa: json['ipa'] as String?,
    );
  }
}