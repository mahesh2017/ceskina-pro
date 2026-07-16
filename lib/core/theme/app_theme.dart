import 'package:flutter/material.dart';

/// App-wide color palette and themes.
class AppColors {
  AppColors._();

  // Primary palette — Czech flag inspired (red, blue, white)
  static const Color primary = Color(0xFF11457E); // Czech blue
  static const Color primaryLight = Color(0xFF3B6BA5);
  static const Color accent = Color(0xFFD7141A); // Czech red
  static const Color accentLight = Color(0xFFE8424E);

  // Gamification colors
  static const Color xpGold = Color(0xFFFFC107);
  static const Color streakOrange = Color(0xFFFF6B35);
  static const Color heartsRed = Color(0xFFE8424E);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color leaguePurple = Color(0xFF7B1FA2);

  // Surfaces
  static const Color surfaceLight = Color(0xFFF5F5F5);
  static const Color surfaceDark = Color(0xFF121212);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E1E1E);
}

 ThemeData lightTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
    ),
  );
}

ThemeData darkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
    ),
  );
}