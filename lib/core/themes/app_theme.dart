import 'package:flutter/material.dart';

class AppTheme {
  // We use static constants for raw colors so you can access them directly if needed
  static const Color oledBlack = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color sosCrimson = Color(0xFFD32F2F);
  static const Color warningAmber = Color(0xFFFFA000);
  static const Color secureGreen = Color(0xFF00C853);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: oledBlack,
      primaryColor: sosCrimson,
      colorScheme: const ColorScheme.dark(
        primary: sosCrimson,
        secondary: warningAmber,
        surface: surfaceDark,
        error: sosCrimson,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: oledBlack,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: sosCrimson,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      // Ensures bottom sheets (like our incident feed) match the aesthetic
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }
}