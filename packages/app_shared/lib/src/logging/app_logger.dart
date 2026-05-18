import 'package:flutter/foundation.dart';

enum _Level { d, i, w, e }

class AppLogger {
  const AppLogger._();

  static void d(String message) => _log(_Level.d, message);
  static void i(String message) => _log(_Level.i, message);
  static void w(String message) => _log(_Level.w, message);
  static void e(String message, {Object? error, StackTrace? stack}) =>
      _log(_Level.e, message, error: error, stack: stack);

  static void _log(
    _Level level,
    String message, {
    Object? error,
    StackTrace? stack,
  }) {
    if (!kDebugMode) return;
    final tag = switch (level) {
      _Level.d => 'D',
      _Level.i => 'I',
      _Level.w => 'W',
      _Level.e => 'E',
    };
    debugPrint('[$tag] $message');
    if (error != null) debugPrint('     error: $error');
    if (stack != null) debugPrint('     stack: $stack');
  }
}
