import 'package:flutter/material.dart';
import 'app_color_scheme.dart';
import 'app_text_styles.dart';

abstract final class AppThemeData {
  static final ThemeData light = _build(AppColorScheme.light);
  static final ThemeData dark = _build(AppColorScheme.dark);

  static ThemeData _build(ColorScheme scheme) {
    final isLight = scheme.brightness == Brightness.light;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: AppTextStyles.textTheme,

      // AppBar: flat, no elevation, centered title
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
        ),
      ),

      // Navigation bar (Material 3 bottom nav)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: scheme.onPrimaryContainer);
          }
          return IconThemeData(color: scheme.onSurfaceVariant);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final base = AppTextStyles.textTheme.labelMedium!;
          if (states.contains(WidgetState.selected)) {
            return base.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w600,
            );
          }
          return base.copyWith(color: scheme.onSurfaceVariant);
        }),
        elevation: 0,
      ),

      // Card: slight elevation, rounded corners
      cardTheme: CardThemeData(
        color: isLight ? scheme.surface : scheme.surfaceContainerHighest,
        elevation: isLight ? 1 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isLight
              ? BorderSide.none
              : BorderSide(color: scheme.outline, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // FAB: primary color, rounded
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        elevation: 2,
      ),

      // Bottom sheet: rounded top corners, drag handle shown
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isLight ? scheme.surface : scheme.surfaceContainerHighest,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
        dragHandleColor: scheme.outline,
        elevation: 0,
      ),

      // Input fields: filled, rounded, used in entry sheets
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight ? scheme.surfaceContainerHighest : scheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: AppTextStyles.textTheme.bodyLarge?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),

      // List tile: compact, no default leading/trailing padding override
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),

      // Switch: alarm on/off toggle
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? scheme.primaryContainer
              : scheme.surfaceContainerHighest;
        }),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // Chip (weekday selector)
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        selectedColor: scheme.primaryContainer,
        labelStyle: AppTextStyles.textTheme.labelMedium?.copyWith(
          color: scheme.onSurface,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: const StadiumBorder(),
        side: BorderSide.none,
      ),

      // Elevated button (e.g., save button in sheets)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.textTheme.labelLarge,
        ),
      ),

      // Text button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: AppTextStyles.textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }
}
