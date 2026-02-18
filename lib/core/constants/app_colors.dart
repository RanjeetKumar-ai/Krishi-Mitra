import 'package:flutter/material.dart';

class AppColors {
  // ==================== PRIMARY COLORS ====================
  static const Color primaryGreen = Color(0xFF388E3C); // Main brand color
  static const Color primaryGreenLight = Color(0xFF66BB6A);
  static const Color primaryGreenDark = Color(0xFF1B5E20);

  // ==================== SECONDARY COLORS ====================
  static const Color secondaryBrown = Color(0xFF6D4C41); // Earth tone
  static const Color secondaryBrownLight = Color(0xFFA1887F);
  static const Color secondaryBrownDark = Color(0xFF3E2723);

  // ==================== ACCENT COLORS ====================
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentYellow = Color(0xFFFFC107);
  static const Color accentBlue = Color(0xFF2196F3);

  // ==================== STATUS COLORS ====================
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFF44336);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color infoBlue = Color(0xFF2196F3);

  // ==================== NEUTRAL COLORS ====================
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color mediumGray = Color(0xFFBDBDBD);
  static const Color darkGray = Color(0xFF424242);
  static const Color charcoal = Color(0xFF212121);

  // ==================== BACKGROUND COLORS ====================
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundCard = Color(0xFFFFFBF0); // Cream for cards
  static const Color backgroundDark = Color(0xFF1F1F1F);

  // ==================== BORDER COLORS ====================
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderMedium = Color(0xFFBDBDBD);
  static const Color borderDark = Color(0xFF616161);

  // ==================== SEMANTIC COLORS ====================
  static const Color fieldBackground = Color(0xFFFFFBF0);
  static const Color fieldBorder = Color(0xFFCCB8A0);
  static const Color disabledGray = Color(0xFFBDBDBD);

  // ==================== GRADIENT COLORS ====================
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGreen, primaryGreenLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient brownGradient = LinearGradient(
    colors: [secondaryBrown, secondaryBrownLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ==================== SHADOW COLORS ====================
  static const Color shadowColor = Color(0x1F000000);
  static const Color shadowColorDark = Color(0x3F000000);

  // ==================== TEXT COLORS ====================
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textInverse = Color(0xFFFFFFFF);

  // ==================== AGRICULTURE SPECIFIC ====================
  static const Color diseaseRed = Color(0xFFE53935); // Disease detection
  static const Color healthyGreen = Color(0xFF43A047); // Healthy crop
  static const Color soilBrown = Color(0xFF8D6E63); // Soil color
  static const Color waterBlue = Color(0xFF1976D2); // Water/irrigation
  static const Color pestOrange = Color(0xFFFB8C00); // Pest warning
}

/// Light Theme Data
class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primaryGreen,
      scaffoldBackgroundColor: AppColors.backgroundLight,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryGreen,
        secondary: AppColors.secondaryBrown,
        tertiary: AppColors.accentOrange,
        error: AppColors.errorRed,
        surface: AppColors.backgroundCard,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onError: AppColors.white,
        onSurface: AppColors.textPrimary,
      ),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        elevation: 2,
        centerTitle: true,
        surfaceTintColor: AppColors.white,
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Input Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.fieldBackground,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.fieldBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.fieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.backgroundCard,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        surfaceTintColor: AppColors.white,
      ),

      // Text Themes
      textTheme: const TextTheme(
        displayLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary),
        displayMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary),
        headlineMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary),
        bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary),
        bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary),
        bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary),
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryGreenLight,
      scaffoldBackgroundColor: AppColors.backgroundDark,
    );
  }
}
