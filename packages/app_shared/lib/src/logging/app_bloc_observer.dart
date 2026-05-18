import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_logger.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    AppLogger.d(
      '${bloc.runtimeType}  ${change.currentState} -> ${change.nextState}',
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    AppLogger.e(
      '${bloc.runtimeType} error',
      error: error,
      stack: stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }
}
