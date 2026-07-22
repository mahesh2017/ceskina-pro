/// App-wide constants.
class AppConstants {
  AppConstants._();

  static const String appName = 'Czechify';
  static const String appVersion = '1.0.0';

  // Database
  static const String dbName = 'czechify.db';

  // Audio
  static const int sampleRate = 16000;
  static const int audioChannels = 1;
  static const int audioBitsPerSample = 16;

  // TTS Cache
  static const String ttsCacheDir = 'tts_cache';
  static const String recordingDir = 'recordings';

  // Gamification
  static const int maxHearts = 5;
  static const int defaultDailyGoalXp = 50;
  static const int heartRegenMinutes = 30;

  // SRS (FSRS)
  static const double targetRetention = 0.9;
  static const int maxIntervalDays = 365;
}