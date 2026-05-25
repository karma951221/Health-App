import 'package:feature_alarm/feature_alarm.dart';
import 'package:feature_alarm/src/data/repositories/alarm_repository_impl.dart';
import 'package:feature_alarm/src/data/schedulers/alarm_ringer_service_impl.dart';
import 'package:feature_settings/feature_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infra_local_db/infra_local_db.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../navigation/app_navigator.dart';
import '../../features/alarm/alarm_ringing_screen.dart';

/// 앱 전체에서 사용할 의존성들을 주입하는 위젯
class AppDependencyProvider extends StatelessWidget {
  const AppDependencyProvider({
    super.key,
    required this.alarmRingerService,
    required this.sharedPreferences,
    required this.child,
  });

  final AlarmRingerService alarmRingerService;
  final SharedPreferences sharedPreferences;
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

        Provider<SharedPreferences>(
          create: (_) => sharedPreferences,
        ),

        Provider<AlarmRingerService>(
          create: (_) => AlarmRingerServiceImpl(),
        ),

        // 2. Alarm UseCases 주입 (Database + 알람 스케줄러에 의존)
        ProxyProvider2<AppDatabase, AlarmRingerService, AlarmUseCases>(
          update: (_, db, ringer, _) {
            final repo = AlarmRepositoryImpl(AlarmLocalDataSource(db));
            return AlarmUseCases(repo, scheduler: ringer);
          },
        ),

        // 3. Settings UseCases 주입 (SharedPreferences에 의존)
        ProxyProvider<SharedPreferences, SettingsUseCases>(
          update: (context, prefs, _) {
            final dataSource = LocalSettingsDataSource(prefs);
            final repository = SettingsRepositoryImpl(dataSource);
            return SettingsUseCases(repository);
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          return _AlarmRingBootstrapper(
            child: MultiBlocProvider(
              providers: [
                // 4. Alarm 관련 Bloc 주입
                BlocProvider<AlarmListBloc>(
                  create: (context) =>
                      AlarmListBloc(context.read<AlarmUseCases>())
                        ..add(const AlarmListEvent.started()),
                ),
              ],
              child: child,
            ),
          );
        },
      ),
    );
  }
}

/// 앱 시작 시 권한 요청 / 알람 재등록 / 울림 이벤트 구독을 담당.
class _AlarmRingBootstrapper extends StatefulWidget {
  const _AlarmRingBootstrapper({required this.child});

  final Widget child;

  @override
  State<_AlarmRingBootstrapper> createState() => _AlarmRingBootstrapperState();
}

class _AlarmRingBootstrapperState extends State<_AlarmRingBootstrapper> {
  var _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;

    // 알람이 울리면 울림 화면으로 이동하도록 구독.
    context.read<AlarmRingerService>().listenForRinging(_handleRing);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrap();
    });
  }

  Future<void> _bootstrap() async {
    await _requestPermissions();

    final useCases = context.read<AlarmUseCases>();
    final ringer = context.read<AlarmRingerService>();
    final alarms = await useCases.watchAlarms().first;
    await ringer.syncFromStore(alarms);
  }

  Future<void> _requestPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  void _handleRing(AlarmNotificationPayload payload) {
    _handleRingAsync(payload); // intentionally not awaited
  }

  Future<void> _handleRingAsync(AlarmNotificationPayload payload) async {
    final useCases = context.read<AlarmUseCases>();
    final alarms = await useCases.watchAlarms().first;

    Alarm? match;
    for (final a in alarms) {
      if (a.id == payload.alarmId) {
        match = a;
        break;
      }
    }
    // 삭제된 알람이 울리는 경쟁 상황 — 안전하게 무시
    if (match == null) return;

    // closure 내에서도 non-nullable로 사용하기 위한 로컬 변수
    final alarm = match;

    final navigator = appNavigatorKey.currentState;
    if (navigator == null) return;

    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => AlarmRingingScreen(
          alarmId: alarm.id,
          hour: alarm.hour,
          minute: alarm.minute,
          label: alarm.label,
          shakeTarget: alarm.shakeCount,
          onDismiss: () => _dismiss(payload.alarmId),
        ),
      ),
    );
  }

  /// 알람 해제 시: 울림 정지 + 반복 알람은 다음 회차로 재예약,
  /// 일회성 알람은 비활성화하여 소진 처리.
  Future<void> _dismiss(int alarmId) async {
    final ringer = context.read<AlarmRingerService>();
    final useCases = context.read<AlarmUseCases>();

    await ringer.stop(alarmId);

    final alarms = await useCases.watchAlarms().first;
    Alarm? match;
    for (final alarm in alarms) {
      if (alarm.id == alarmId) {
        match = alarm;
        break;
      }
    }
    if (match == null) {
      return;
    }

    if (match.weekdayMask == 0) {
      await useCases.toggleAlarm(alarm: match, enabled: false);
    } else {
      await useCases.updateAlarm(match);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
