import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _borderRadius = 12.0;
  static const _snackBarBorderRadius = 8.0;
  static const _primaryColor = Colors.blue;
  
  static ThemeData _baseTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final baseTextTheme = isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: brightness,
      ).copyWith(
        surface: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        onSurface: isDark ? Colors.white : Colors.black87,
        surfaceContainerHighest: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF5F5F5),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(baseTextTheme).copyWith(
        bodyLarge: TextStyle(
          fontSize: 16,
          color: isDark ? Colors.white : Colors.black87,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.white70 : Colors.black54,
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      chipTheme: ChipThemeData(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius / 2),
        ),
        labelStyle: TextStyle(
          fontSize: 13,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_snackBarBorderRadius),
        ),
        contentTextStyle: const TextStyle(fontSize: 14),
        backgroundColor: isDark ? const Color(0xFF323232) : const Color(0xFF323232),
      ),
      dividerTheme: DividerThemeData(
        space: 16,
        thickness: 0.5,
        color: isDark ? Colors.white12 : Colors.black12,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: BorderSide(
            color: isDark ? Colors.white24 : Colors.black12,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: BorderSide(
            color: isDark ? Colors.white24 : Colors.black12,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: const BorderSide(
            color: _primaryColor,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
      ),
    );
  }

  static ThemeData get lightTheme => _baseTheme(Brightness.light);
  static ThemeData get darkTheme => _baseTheme(Brightness.dark);
}