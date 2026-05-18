import 'package:feature_alarm/feature_alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infra_local_db/infra_local_db.dart';
import 'package:provider/provider.dart';

/// 앱 전체에서 사용할 의존성들을 주입하는 위젯
class AppDependencyProvider extends StatelessWidget {
  const AppDependencyProvider({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 1. Database 주입
        Provider<AppDatabase>(
          create: (_) => AppDatabase(),
          dispose: (_, db) => db.close(),
        ),

        // 2. Alarm UseCases 주입 (Database에 의존)
        ProxyProvider<AppDatabase, AlarmUseCases>(
          update: (_, db, __) {
            final repo = AlarmRepositoryImpl(AlarmLocalDataSource(db));
            return AlarmUseCases(repo);
          },
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // 3. Alarm 관련 Bloc 주입
          BlocProvider<AlarmListBloc>(
            create: (context) => AlarmListBloc(
              context.read<AlarmUseCases>(),
            )..add(const AlarmListEvent.started()),
          ),

          // TODO: 식단(Meal), 운동(Workout) Bloc 추가 예정
        ],
        child: child,
      ),
    );
  }
}
