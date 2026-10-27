import 'package:flutter/material.dart';

class AppTheme {
  static const Color _primaryRed = Color(0xFFE50914);
  static const Color _darkBackground = Color(0xFF0A0A0F);
  static const Color _darkSurface = Color(0xFF141420);
  static const Color _cardColor = Color(0xFF1E1E2E);
  static const Color _textPrimary = Color(0xFFF0F0F0);
  static const Color _textSecondary = Color(0xFF9E9E9E);
  static const Color _starColor = Color(0xFFFFD700);

  static const Color primaryRed = _primaryRed;
  static const Color darkBackground = _darkBackground;
  static const Color cardColor = _cardColor;
  static const Color textSecondary = _textSecondary;
  static const Color starColor = _starColor;

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _primaryRed,
        secondary: Color(0xFFFF6B6B),
        surface: _darkSurface,
        onPrimary: Colors.white,
        onSurface: _textPrimary,
        error: Color(0xFFCF6679),
      ),
      scaffoldBackgroundColor: _darkBackground,
      cardColor: _cardColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkBackground,
        foregroundColor: _textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: _textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _darkSurface,
        selectedItemColor: _primaryRed,
        unselectedItemColor: _textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _darkSurface,
        indicatorColor: _primaryRed.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: _primaryRed, fontSize: 12, fontWeight: FontWeight.w600);
          }
          return const TextStyle(color: _textSecondary, fontSize: 12);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: _primaryRed);
          }
          return const IconThemeData(color: _textSecondary);
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryRed, width: 1.5),
        ),
        hintStyle: const TextStyle(color: _textSecondary),
        prefixIconColor: _textSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: _textPrimary, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: _textPrimary, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: _textPrimary, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: _textPrimary, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: _textSecondary),
        bodyLarge: TextStyle(color: _textPrimary),
        bodyMedium: TextStyle(color: _textSecondary),
        bodySmall: TextStyle(color: _textSecondary, fontSize: 12),
        labelLarge: TextStyle(color: _textPrimary, fontWeight: FontWeight.w600),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _cardColor,
        selectedColor: _primaryRed.withValues(alpha: 0.3),
        labelStyle: const TextStyle(color: _textPrimary, fontSize: 12),
        side: const BorderSide(color: Color(0xFF2E2E3E)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryRed,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: _textPrimary),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFF2E2E3E)),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _cardColor,
        contentTextStyle: const TextStyle(color: _textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: _primaryRed,
        secondary: const Color(0xFFFF6B6B),
        surface: Colors.grey.shade50,
        onPrimary: Colors.white,
        error: const Color(0xFFB00020),
      ),
      scaffoldBackgroundColor: Colors.grey.shade100,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey.shade100,
        foregroundColor: Colors.grey.shade900,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.grey.shade900,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: _primaryRed.withValues(alpha: 0.15),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryRed,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
