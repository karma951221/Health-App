import 'dart:async';
import 'dart:ui';

class Throttler {
  Throttler({required this.interval});

  final Duration interval;
  Timer? _cooldown;

  void call(VoidCallback action) {
    if (_cooldown != null) return;
    action();
    _cooldown = Timer(interval, () => _cooldown = null);
  }

  void cancel() {
    _cooldown?.cancel();
    _cooldown = null;
  }

  void dispose() => cancel();
}
