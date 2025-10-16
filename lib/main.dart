import 'package:flutter/material.dart';
import 'core/notification_service.dart';
import 'theme/app_theme.dart';
import 'ui/home_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/task.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  await NotificationService().init();
  await NotificationService().requestPermissionsIfNeeded();

  runApp(const PlannerApp());
}

class PlannerApp extends StatelessWidget {
  const PlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ramazan Planner',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}
