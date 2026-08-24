import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'screens/mood_input_screen.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<void> deleteOldDB() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'behavior.db');
  await deleteDatabase(path);
}

final GlobalKey<NavigatorState> navigatorKey =
GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 TEMPORARY (run once, then remove)


  await NotificationService.init((payload) {
    if (payload == "mood") {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => const MoodInputScreen(),
        ),
      );
    }
  });

  runApp(const BehaviorMonitorApp()); // ✅ CORRECT
}

class BehaviorMonitorApp extends StatelessWidget {
  const BehaviorMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: "Behavior Monitor",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF4A90E2),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4A90E2),
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4A90E2),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}