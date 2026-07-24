// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Czechify';

  @override
  String get check => 'Check';

  @override
  String get continueLabel => 'Continue';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get nextPhrase => 'Next Phrase';

  @override
  String get skip => 'Skip';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get goHome => 'Go Home';

  @override
  String get startExam => 'Start Exam';

  @override
  String get resumeExam => 'Resume Exam';

  @override
  String get discardAndStartOver => 'Discard and start over';

  @override
  String get startRecording => 'Start recording';

  @override
  String get stopRecording => 'Stop recording';

  @override
  String get listen => 'Listen';

  @override
  String get pronunciationLab => 'Pronunciation Lab';

  @override
  String get sayThis => 'Say this:';

  @override
  String get tapMicrophoneHint => 'Tap the microphone and say the phrase';

  @override
  String get analyzingPronunciation => 'Analyzing your pronunciation...';

  @override
  String get onDeviceRecognitionNote =>
      'Using on-device recognition — results may be less accurate.';
}
