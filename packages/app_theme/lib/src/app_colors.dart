import 'package:flutter/material.dart';

/// Design system color palette (raw tokens, no semantic meaning).
///
/// All colors are `static const` and accessed via [AppColors.zinc900], etc.
/// Do not instantiate this class.
abstract final class AppColors {
  /// Zinc Scale
  static const Color zinc900 = Color(0xFF18181B);
  static const Color zinc800 = Color(0xFF27272A);
  static const Color zinc700 = Color(0xFF3F3F46);
  static const Color zinc500 = Color(0xFF71717A);
  static const Color zinc400 = Color(0xFFA1A1AA);
  static const Color zinc200 = Color(0xFFE4E4E7);
  static const Color zinc100 = Color(0xFFF4F4F5);
  static const Color zinc50 = Color(0xFFFAFAFA);

  /// Red Scale (primary accent)
  static const Color red500 = Color(0xFFEF4444);
  static const Color red800 = Color(0xFF991B1B);
  static const Color red200 = Color(0xFFFECACA);
}
