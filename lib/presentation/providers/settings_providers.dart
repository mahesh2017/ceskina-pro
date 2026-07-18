import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/enums.dart';
import 'llm_providers.dart';

/// Theme mode enum.
enum AppThemeMode { system, light, dark }

/// App-wide settings state.
class AppSettings {
  final AppThemeMode themeMode;
  final int dailyGoalXp;
  final double ttsSpeechRate;
  final bool hasApiKey;
  final CEFRLevel startingLevel;

  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.dailyGoalXp = 50,
    this.ttsSpeechRate = 0.45,
    this.hasApiKey = false,
    this.startingLevel = CEFRLevel.preA1,
  });

  AppSettings copyWith({
    AppThemeMode? themeMode,
    int? dailyGoalXp,
    double? ttsSpeechRate,
    bool? hasApiKey,
    CEFRLevel? startingLevel,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      dailyGoalXp: dailyGoalXp ?? this.dailyGoalXp,
      ttsSpeechRate: ttsSpeechRate ?? this.ttsSpeechRate,
      hasApiKey: hasApiKey ?? this.hasApiKey,
      startingLevel: startingLevel ?? this.startingLevel,
    );
  }
}

/// Notifier that manages app settings persisted to SharedPreferences.
class SettingsNotifier extends Notifier<AppSettings> {
  static const _kThemeMode = 'settings_theme_mode';
  static const _kDailyGoalXp = 'settings_daily_goal_xp';
  static const _kTtsRate = 'settings_tts_rate';
  static const _kOnboardingDone = 'settings_onboarding_done';
  static const _kStartingLevel = 'settings_starting_level';

  @override
  AppSettings build() {
    _loadSettings();
    return const AppSettings();
  }

  /// Prefs accessor — always awaited so setters can't race the initial load.
  Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  Future<void> _loadSettings() async {
    final prefs = await _prefs();
    final themeIdx = prefs.getInt(_kThemeMode) ?? 0;
    final dailyGoal = prefs.getInt(_kDailyGoalXp) ?? 50;
    final ttsRate = prefs.getDouble(_kTtsRate) ?? 0.45;
    final levelIdx = prefs.getInt(_kStartingLevel) ?? 0;

    // Check if API key is set
    final storage = ref.read(secureStorageProvider);
    final apiKey = await storage.read(key: kDeepSeekApiKeyStorageKey);

    state = AppSettings(
      themeMode: AppThemeMode
          .values[themeIdx.clamp(0, AppThemeMode.values.length - 1)],
      dailyGoalXp: dailyGoal,
      ttsSpeechRate: ttsRate,
      hasApiKey: apiKey != null && apiKey.isNotEmpty,
      startingLevel:
          CEFRLevel.values[levelIdx.clamp(0, CEFRLevel.values.length - 1)],
    );
  }

  /// Set the theme mode.
  Future<void> setThemeMode(AppThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await _prefs();
    await prefs.setInt(_kThemeMode, mode.index);
  }

  /// Set the daily XP goal.
  Future<void> setDailyGoalXp(int xp) async {
    state = state.copyWith(dailyGoalXp: xp);
    final prefs = await _prefs();
    await prefs.setInt(_kDailyGoalXp, xp);
  }

  /// Set the TTS speech rate.
  Future<void> setTtsSpeechRate(double rate) async {
    state = state.copyWith(ttsSpeechRate: rate);
    final prefs = await _prefs();
    await prefs.setDouble(_kTtsRate, rate);
  }

  /// Set the learner's self-assessed starting level (from onboarding).
  Future<void> setStartingLevel(CEFRLevel level) async {
    state = state.copyWith(startingLevel: level);
    final prefs = await _prefs();
    await prefs.setInt(_kStartingLevel, level.index);
  }

  /// Save the DeepSeek API key.
  Future<void> setApiKey(String key) async {
    final storage = ref.read(secureStorageProvider);
    await storage.write(key: kDeepSeekApiKeyStorageKey, value: key);
    ref.invalidate(apiKeyProvider);
    state = state.copyWith(hasApiKey: key.isNotEmpty);
  }

  /// Clear the API key.
  Future<void> clearApiKey() async {
    final storage = ref.read(secureStorageProvider);
    await storage.delete(key: kDeepSeekApiKeyStorageKey);
    ref.invalidate(apiKeyProvider);
    state = state.copyWith(hasApiKey: false);
  }

  /// Check if onboarding has been completed.
  Future<bool> isOnboardingDone() async {
    final prefs = await _prefs();
    return prefs.getBool(_kOnboardingDone) ?? false;
  }

  /// Mark onboarding as complete.
  Future<void> completeOnboarding() async {
    final prefs = await _prefs();
    await prefs.setBool(_kOnboardingDone, true);
  }
}

/// Provider for app settings.
final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

/// Provider that converts AppThemeMode to Flutter's ThemeMode.
final themeModeProvider = Provider<ThemeMode>((ref) {
  final settings = ref.watch(settingsProvider);
  return switch (settings.themeMode) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
  };
});

/// Whether onboarding has been completed — read once at startup to pick
/// the router's initial location (onboarding invalidates it on finish).
final onboardingDoneProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('settings_onboarding_done') ?? false;
});
