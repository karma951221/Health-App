import 'package:alarm/alarm.dart' as alarm_pkg;
import 'package:app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:feature_alarm/feature_alarm.dart';
import 'package:feature_alarm/src/data/schedulers/alarm_ringer_service_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/dependency_injection/dependency_injection.dart';
import 'core/navigation/app_navigator.dart';
import 'core/splash/splash_screen.dart';
import 'features/home/home_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initializes the alarm service and restores any persisted alarms.
  await alarm_pkg.Alarm.init();
  // Initialize SharedPreferences for settings
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    AppDependencyProvider(
      alarmRingerService: AlarmRingerServiceImpl(),
      sharedPreferences: sharedPreferences,
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool _showSplash = true;

  void _completeSplash() {
    setState(() {
      _showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      title: 'karma',
      theme: AppThemeData.light,
      darkTheme: AppThemeData.dark,
      themeMode: ThemeMode.system,
      home: _showSplash
          ? SplashScreen(onSplashComplete: _completeSplash)
          : const HomeShell(),
    );
  }
}
