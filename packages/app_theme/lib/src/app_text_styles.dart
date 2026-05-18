import 'package:flutter/material.dart';

abstract final class AppTextStyles {
  static const String _font = 'Pretendard';

  static const TextTheme textTheme = TextTheme(
    // Display — big numbers (alarm clock face, stats)
    displayLarge: TextStyle(
      fontFamily: _font,
      fontWeight: FontWeight.w400,
      fontSize: 57,
      letterSpacing: -0.25,
    ),
    displayMedium: TextStyle(
      fontFamily: _font,
      fontWeight: FontWeight.w400,
      fontSize: 45,
    ),
    displaySmall: TextStyle(
      fontFamily: _font,
      fontWeight: FontWeight.w400,
      fontSize: 36,
    ),

    // Headline — section headers, date header
    headlineLarge: TextStyle(
      fontFamily: _font,
      fontWeight: FontWeight.w600,
      fontSize: 32,
    ),
    headlineMedium: TextStyle(
      fontFamily: _font,
      fontWeight: FontWeight.w600,
      fontSize: 28,
    ),
    headlineSmall: TextStyle(
      fontFamily: _font,
      fontWeight: FontWeight.w600,
      fontSize: 24,
    ),

    // Title — list tile primary text, sheet titles
    titleLarge: TextStyle(
      fontFamily: _font,
      fontWeight: FontWeight.w600,
      fontSize: 22,
    ),
    titleMedium: TextStyle(
      fontFamily: _font,
      fontWeight: FontWeight.w500,
      fontSize: 16,
      letterSpacing: 0.15,
    ),
    titleSmall: TextStyle(
      fontFamily: _font,
      fontWeight: FontWeight.w500,
      fontSize: 14,
      letterSpacing: 0.1,
    ),

    // Body — memo text, list secondary text
    bodyLarge: TextStyle(
      fontFamily: _font,
      fontWeight: FontWeight.w400,
      fontSize: 16,
      letterSpacing: 0.5,
    ),
    bodyMedium: TextStyle(
      fontFamily: _font,
      fontWeight: FontWeight.w400,
      fontSize: 14,
      letterSpacing: 0.25,
    ),
    bodySmall: TextStyle(
      fontFamily: _font,
      fontWeight: FontWeight.w400,
      fontSize: 12,
      letterSpacing: 0.4,
    ),

    // Label — buttons, chips, weekday badges, tab labels
    labelLarge: TextStyle(
      fontFamily: _font,
      fontWeight: FontWeight.w600,
      fontSize: 14,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontFamily: _font,
      fontWeight: FontWeight.w500,
      fontSize: 12,
      letterSpacing: 0.5,
    ),
    labelSmall: TextStyle(
      fontFamily: _font,
      fontWeight: FontWeight.w500,
      fontSize: 11,
      letterSpacing: 0.5,
    ),
  );
}
