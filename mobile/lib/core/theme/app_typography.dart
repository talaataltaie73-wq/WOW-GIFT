import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextTheme get textTheme {
    return GoogleFonts.tajawalTextTheme(
      const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, height: 1.3),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.3),
        displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1.3),
        headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.4),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.4),
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.4),
        titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.5),
        titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.5),
        titleSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1.5),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.6),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.6),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.6),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.4),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.4),
        labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, height: 1.4),
      ),
    );
  }
}
