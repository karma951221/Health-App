import 'package:app_shared/src/logging/app_bloc_observer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _CounterCubit extends Cubit<int> {
  _CounterCubit() : super(0);
  void inc() => emit(state + 1);
  void boom() => addError(StateError('bad'), StackTrace.current);
}

void main() {
  group('AppBlocObserver', () {
    late List<String> captured;
    late DebugPrintCallback original;
    late BlocObserver previousObserver;

    setUp(() {
      captured = [];
      original = debugPrint;
      debugPrint = (String? msg, {int? wrapWidth}) {
        if (msg != null) captured.add(msg);
      };
      previousObserver = Bloc.observer;
      Bloc.observer = AppBlocObserver();
    });

    tearDown(() {
      debugPrint = original;
      Bloc.observer = previousObserver;
    });

    test('logs cubit state changes', () {
      final cubit = _CounterCubit();
      cubit.inc();
      cubit.inc();
      cubit.close();

      final joined = captured.join('\n');
      expect(joined, contains('_CounterCubit'));
      expect(joined, contains('0'));
      expect(joined, contains('1'));
      expect(joined, contains('2'));
    });

    test('logs errors raised inside blocs', () {
      final cubit = _CounterCubit();
      cubit.boom();
      cubit.close();

      final joined = captured.join('\n');
      expect(joined, contains('bad'));
    });
  });
}
