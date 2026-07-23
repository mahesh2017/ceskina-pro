/// A flashcard for vocabulary learning.
class Flashcard {
  final int id;
  final String wordCz;
  final String wordEn;
  final String? ipa;
  final String?
  gender; // masculine animate, masculine inanimate, feminine, neuter
  final String? caseInfo;
  final String? audioHash;
  final String? imagePath;
  final String? exampleCz;
  final String? exampleEn;
  final String? lemma;
  final String? senseKey;
  final String? partOfSpeech;
  final String? morphologyJson;
  final String? registerLabel;
  final String? pronunciationSource;
  final int? unitId;
  final int? lessonId;

  const Flashcard({
    required this.id,
    required this.wordCz,
    required this.wordEn,
    this.ipa,
    this.gender,
    this.caseInfo,
    this.audioHash,
    this.imagePath,
    this.exampleCz,
    this.exampleEn,
    this.lemma,
    this.senseKey,
    this.partOfSpeech,
    this.morphologyJson,
    this.registerLabel,
    this.pronunciationSource,
    this.unitId,
    this.lessonId,
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'] as int,
      wordCz: json['word_cz'] as String,
      wordEn: json['word_en'] as String,
      ipa: json['ipa'] as String?,
      gender: json['gender'] as String?,
      caseInfo: json['case_info'] as String?,
      audioHash: json['audio_hash'] as String?,
      imagePath: json['image_path'] as String?,
      exampleCz: json['example_cz'] as String?,
      exampleEn: json['example_en'] as String?,
      lemma: json['lemma'] as String?,
      senseKey: json['sense_key'] as String?,
      partOfSpeech: json['part_of_speech'] as String?,
      morphologyJson: json['morphology_json'] as String?,
      registerLabel: json['register_label'] as String?,
      pronunciationSource: json['pronunciation_source'] as String?,
      unitId: json['unit_id'] as int?,
      lessonId: json['lesson_id'] as int?,
    );
  }
}
