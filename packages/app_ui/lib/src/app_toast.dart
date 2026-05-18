import 'package:flutter/material.dart';

enum ToastType { success, warning, error }

extension _ToastTypeX on ToastType {
  Color get backgroundColor => switch (this) {
        ToastType.success => const Color(0xFF16A34A),
        ToastType.warning => const Color(0xFFD97706),
        ToastType.error => const Color(0xFFEF4444),
      };

  IconData get icon => switch (this) {
        ToastType.success => Icons.check_circle_outline,
        ToastType.warning => Icons.warning_amber_outlined,
        ToastType.error => Icons.error_outline,
      };
}

void showAppToast(
  BuildContext context,
  String message, {
  ToastType type = ToastType.success,
}) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(type.icon, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: type.backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(milliseconds: 2500),
        elevation: 4,
      ),
    );
}
