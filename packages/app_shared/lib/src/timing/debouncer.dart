import 'dart:async';
import 'dart:ui';

class Debouncer {
  Debouncer({required this.delay});

  final Duration delay;
  Timer? _timer;
  bool _disposed = false;

  void call(VoidCallback action) {
    if (_disposed) return;
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    cancel();
    _disposed = true;
  }
}
