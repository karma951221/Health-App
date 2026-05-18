import 'package:app_theme/app_theme.dart';
import 'package:flutter/material.dart';

import 'core/dependency_injection/dependency_injection.dart';
import 'features/home/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const AppDependencyProvider(
      child: MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daylog',
      theme: AppThemeData.light,
      darkTheme: AppThemeData.dark,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
