import 'package:flutter/material.dart';

class AppColors {
  // Primary dark navy (from screenshot)
  static const Color darkNavy = Color(0xFF0D1B2A);
  static const Color navy = Color(0xFF1A2D42);
  static const Color navyLight = Color(0xFF1E3448);

  // Accent - warm gold/yellow
  static const Color accent = Color(0xFFF5A623);
  static const Color accentLight = Color(0xFFFFBF47);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textHint = Color(0xFF607D8B);

  // Divider / border
  static const Color navyBorder = Color(0xFF2A4560);

  // Input fields
  static const Color inputBg = Color(0xFF1E3448);
  static const Color inputBorder = Color(0xFF2A4560);
  static const Color inputBorderFocused = Color(0xFFF5A623);

  // Card
  static const Color navyCard   = Color(0xFF1A2D42);
  static const Color cardBg     = Color(0xFFFFFFFF);
  static const Color cardShadow = Color(0x1A000000);

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFEF5350);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.darkNavy,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          surface: AppColors.navy,
          error: AppColors.error,
        ),
        fontFamily: 'SF Pro Display',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.inputBg,
          hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.inputBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.inputBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.inputBorderFocused, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            elevation: 0,
          ),
        ),
      );
}