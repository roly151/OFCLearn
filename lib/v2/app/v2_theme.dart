import 'package:flutter/material.dart';

class V2Palette {
  const V2Palette._();

  static const canvas = Color(0xFFF4F1E8);
  static const surface = Color(0xFFFFFCF7);
  static const ink = Color(0xFF15263F);
  static const muted = Color(0xFF5D6B7C);
  static const primaryBlue = Color(0xFF123B67);
  static const deepBlue = Color(0xFF0C2747);
  static const foliage = Color(0xFF4F8A3C);
  static const sand = Color(0xFFD2B16C);
  static const seaGlass = Color(0xFFDDE9D7);
  static const mist = Color(0xFFE3E8EE);
  static const cardBorder = Color(0xFFD8DFE5);
  static const fieldBorder = Color(0xFFC8D1DA);
  static const navIndicator = Color(0xFFD9E4F1);
}

ThemeData buildV2Theme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: V2Palette.primaryBlue,
    brightness: Brightness.light,
    primary: V2Palette.primaryBlue,
    secondary: V2Palette.foliage,
    tertiary: V2Palette.sand,
    surface: V2Palette.surface,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: V2Palette.canvas,
    fontFamily: 'WorkSans',
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        height: 1.05,
        color: V2Palette.ink,
      ),
      headlineMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: V2Palette.ink,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: V2Palette.ink,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: V2Palette.ink,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: V2Palette.ink,
        height: 1.45,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: V2Palette.muted,
        height: 1.45,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      color: V2Palette.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(color: V2Palette.cardBorder),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.88),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: V2Palette.fieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: V2Palette.primaryBlue, width: 1.4),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: V2Palette.surface,
      indicatorColor: V2Palette.navIndicator,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
          color: V2Palette.ink,
        ),
      ),
    ),
  );
}
