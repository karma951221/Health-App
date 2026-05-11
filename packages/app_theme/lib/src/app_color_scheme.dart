import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Material 3 ColorScheme definitions for daylog.
///
/// Light and dark schemes are explicitly defined with all tokens mapped
/// to AppColors — ColorScheme.fromSeed is not used to preserve Zinc
/// background colors.
abstract final class AppColorScheme {
  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.red500,
    onPrimary: AppColors.zinc50,
    primaryContainer: AppColors.red200,
    onPrimaryContainer: AppColors.red800,
    secondary: AppColors.zinc500,
    onSecondary: AppColors.zinc50,
    surface: AppColors.zinc50,
    onSurface: AppColors.zinc900,
    surfaceContainerHighest: AppColors.zinc100,
    onSurfaceVariant: AppColors.zinc500,
    outline: AppColors.zinc200,
    outlineVariant: AppColors.zinc100,
    error: AppColors.red500,
    onError: AppColors.zinc50,
    errorContainer: AppColors.red200,
    onErrorContainer: AppColors.red800,
    shadow: Color(0x1A000000),
    scrim: Color(0x1A000000),
  );

  static const ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.red500,
    onPrimary: AppColors.zinc50,
    primaryContainer: AppColors.red800,
    onPrimaryContainer: AppColors.red200,
    secondary: AppColors.zinc400,
    onSecondary: AppColors.zinc900,
    surface: AppColors.zinc900,
    onSurface: AppColors.zinc50,
    surfaceContainerHighest: AppColors.zinc800,
    onSurfaceVariant: AppColors.zinc400,
    outline: AppColors.zinc700,
    outlineVariant: AppColors.zinc700,
    error: AppColors.red500,
    onError: AppColors.zinc50,
    errorContainer: AppColors.red800,
    onErrorContainer: AppColors.red200,
    shadow: Color(0x1A000000),
    scrim: Color(0x1A000000),
  );
}
