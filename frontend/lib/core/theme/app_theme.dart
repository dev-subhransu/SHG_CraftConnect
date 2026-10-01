import 'package:flutter/material.dart';

class AppColors {
  // Cultural Artisan & SHG Palette (Terracotta, Indigo, Ochre & Parchment)
  static const Color terracotta = Color(0xFFC85A32);
  static const Color deepTerracotta = Color(0xFFA83F1C);
  static const Color ochre = Color(0xFFE29578);
  static const Color saffron = Color(0xFFE76F51);
  static const Color deepIndigo = Color(0xFF1E2D3E);
  static const Color forestGreen = Color(0xFF2A9D8F);
  static const Color goldAccent = Color(0xFFE9C46A);
  
  // Neutral surfaces
  static const Color parchment = Color(0xFFF9F6F0);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF121212);
  static const Color cardLight = Color(0xFFFFFFFF);
  
  // Typography
  static const Color textDark = Color(0xFF2B2D42);
  static const Color textMuted = Color(0xFF6C757D);
  static const Color textLight = Color(0xFFF8F9FA);

  // Status
  static const Color soldOutBadge = Color(0xFFD90429);
  static const Color inStockBadge = Color(0xFF2A9D8F);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.terracotta,
        primary: AppColors.terracotta,
        secondary: AppColors.deepIndigo,
        tertiary: AppColors.forestGreen,
        surface: AppColors.parchment,
        surfaceContainerHighest: const Color(0xFFF0EAE1),
      ),
      scaffoldBackgroundColor: AppColors.parchment,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.parchment,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textDark),
        titleTextStyle: TextStyle(
          color: AppColors.textDark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.terracotta,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        modalBackgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        showDragHandle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.terracotta, width: 2),
        ),
        labelStyle: TextStyle(color: Colors.grey.shade700),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: 1.5,
        shadowColor: Colors.black.withOpacity(0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}
