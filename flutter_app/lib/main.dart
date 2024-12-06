import 'package:flutter/material.dart';
import '../service/NotificationService.dart';
import 'themes/app_theme.dart';
import 'routes/app_routes.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await NotificationService.initNotifications();
  await NotificationService.requestPermissions();
  runApp(MyApp()); // Starts the app
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SerenCoach',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: AppRoutes.routes,
    );
  }
}
