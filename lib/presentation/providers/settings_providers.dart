import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'llm_providers.dart';

/// Theme mode enum.
enum AppThemeMode { system, light, dark }

/// App-wide settings state.
class AppSettings {
  final AppThemeMode themeMode;
  final int dailyGoalXp;
  final double ttsSpeechRate;
  final bool hasApiKey;

  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.dailyGoalXp = 50,
    this.ttsSpeechRate = 0.45,
    this.hasApiKey = false,
  });

  AppSettings copyWith({
    AppThemeMode? themeMode,
    int? dailyGoalXp,
    double? ttsSpeechRate,
    bool? hasApiKey,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      dailyGoalXp: dailyGoalXp ?? this.dailyGoalXp,
      ttsSpeechRate: ttsSpeechRate ?? this.ttsSpeechRate,
      hasApiKey: hasApiKey ?? this.hasApiKey,
    );
  }
}

/// Notifier that manages app settings persisted to SharedPreferences.
class SettingsNotifier extends Notifier<AppSettings> {
  late SharedPreferences _prefs;

  static const _kThemeMode = 'settings_theme_mode';
  static const _kDailyGoalXp = 'settings_daily_goal_xp';
  static const _kTtsRate = 'settings_tts_rate';
  static const _kOnboardingDone = 'settings_onboarding_done';

  @override
  AppSettings build() {
    _loadSettings();
    return const AppSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    final themeIdx = _prefs.getInt(_kThemeMode) ?? 0;
    final dailyGoal = _prefs.getInt(_kDailyGoalXp) ?? 50;
    final ttsRate = _prefs.getDouble(_kTtsRate) ?? 0.45;

    // Check if API key is set
    final storage = ref.read(secureStorageProvider);
    final apiKey = await storage.read(key: 'deepseek_api_key');

    state = AppSettings(
      themeMode: AppThemeMode.values[themeIdx],
      dailyGoalXp: dailyGoal,
      ttsSpeechRate: ttsRate,
      hasApiKey: apiKey != null && apiKey.isNotEmpty,
    );
  }

  /// Set the theme mode.
  Future<void> setThemeMode(AppThemeMode mode) async {
    await _prefs.setInt(_kThemeMode, mode.index);
    state = state.copyWith(themeMode: mode);
  }

  /// Set the daily XP goal.
  Future<void> setDailyGoalXp(int xp) async {
    await _prefs.setInt(_kDailyGoalXp, xp);
    state = state.copyWith(dailyGoalXp: xp);
  }

  /// Set the TTS speech rate.
  Future<void> setTtsSpeechRate(double rate) async {
    await _prefs.setDouble(_kTtsRate, rate);
    state = state.copyWith(ttsSpeechRate: rate);
  }

  /// Save the DeepSeek API key.
  Future<void> setApiKey(String key) async {
    final storage = ref.read(secureStorageProvider);
    await storage.write(key: 'deepseek_api_key', value: key);
    ref.invalidate(apiKeyProvider);
    state = state.copyWith(hasApiKey: key.isNotEmpty);
  }

  /// Clear the API key.
  Future<void> clearApiKey() async {
    final storage = ref.read(secureStorageProvider);
    await storage.delete(key: 'deepseek_api_key');
    ref.invalidate(apiKeyProvider);
    state = state.copyWith(hasApiKey: false);
  }

  /// Check if onboarding has been completed.
  Future<bool> isOnboardingDone() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs.getBool(_kOnboardingDone) ?? false;
  }

  /// Mark onboarding as complete.
  Future<void> completeOnboarding() async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs.setBool(_kOnboardingDone, true);
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