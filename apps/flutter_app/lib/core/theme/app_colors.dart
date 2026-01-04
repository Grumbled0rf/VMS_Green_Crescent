import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ==========================================
  // LIGHT THEME COLORS
  // ==========================================
  
  // Primary Colors
  static const Color primary = Color(0xFF1E88E5);
  static const Color primaryLight = Color(0xFFE3F2FD);
  static const Color primaryDark = Color(0xFF1565C0);

  // Secondary Colors
  static const Color secondary = Color(0xFF43A047);
  static const Color secondaryLight = Color(0xFFE8F5E9);

  // Accent Colors
  static const Color accent = Color(0xFFFF9800);
  static const Color accentLight = Color(0xFFFFF3E0);

  // Status Colors
  static const Color success = Color(0xFF43A047);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFFFA726);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF29B6F6);
  static const Color infoLight = Color(0xFFE1F5FE);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);

  // Text Colors
  static const Color dark = Color(0xFF212121);
  static const Color gray = Color(0xFF757575);
  static const Color lightGray = Color(0xFFBDBDBD);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFF1976D2)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, Color(0xFF2E7D32)],
  );

  // ==========================================
  // DARK THEME COLORS
  // ==========================================
  
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2C2C2C);
  static const Color darkBorder = Color(0xFF3D3D3D);
  static const Color darkDivider = Color(0xFF424242);
  
  // Dark Text Colors
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB3B3B3);
  static const Color darkTextHint = Color(0xFF757575);

  // Dark Primary (slightly brighter for dark mode)
  static const Color darkPrimary = Color(0xFF42A5F5);
  static const Color darkPrimaryLight = Color(0xFF1E3A5F);

  // Dark Gradients
  static const LinearGradient darkPrimaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkPrimary, Color(0xFF1E88E5)],
  );
}

// ==========================================
// THEME EXTENSION FOR EASY ACCESS
// ==========================================
extension AppColorsExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  
  Color get backgroundColor => isDarkMode ? AppColors.darkBackground : AppColors.background;
  Color get surfaceColor => isDarkMode ? AppColors.darkSurface : AppColors.surface;
  Color get cardColor => isDarkMode ? AppColors.darkCard : AppColors.white;
  Color get borderColor => isDarkMode ? AppColors.darkBorder : AppColors.border;
  Color get textPrimaryColor => isDarkMode ? AppColors.darkTextPrimary : AppColors.dark;
  Color get textSecondaryColor => isDarkMode ? AppColors.darkTextSecondary : AppColors.gray;
  Color get primaryColor => isDarkMode ? AppColors.darkPrimary : AppColors.primary;
  Color get primaryLightColor => isDarkMode ? AppColors.darkPrimaryLight : AppColors.primaryLight;
}