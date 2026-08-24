import 'package:flutter/material.dart';

import 'input_screen.dart';
import 'dashboard_screen.dart';
import 'mood_input_screen.dart';
import 'usage_permission_screen.dart';
import 'calculation_screen.dart';
import '../database/database_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget featureCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Widget? page, {
    required List<Color> gradientColors,
    VoidCallback? onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ??
              () {
                if (page != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => page),
                  );
                }
              },
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: gradientColors[0].withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Confirm Factory Reset"),
        content: const Text(
          "This will delete all your data permanently. This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await DatabaseService.factoryReset();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("App has been reset successfully")),
                );
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text(
              "Reset",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.purple.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Header Section
              Container(
                padding: const EdgeInsets.all(24),
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade700, Colors.purple.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Behavior Monitor",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Icon(Icons.spa, color: Colors.white, size: 32),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Track your mental wellness",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    featureCard(
                      context,
                      "Daily Behavior",
                      "Track sleep, routine and habits",
                      Icons.psychology,
                      const InputScreen(),
                      gradientColors: [Colors.blue.shade400, Colors.blue.shade700],
                    ),
                    featureCard(
                      context,
                      "Mood Check",
                      "Log your current mood",
                      Icons.emoji_emotions,
                      const MoodInputScreen(),
                      gradientColors: [Colors.orange.shade400, Colors.orange.shade700],
                    ),
                    featureCard(
                      context,
                      "Stability Dashboard",
                      "View mental stability analysis",
                      Icons.analytics,
                      const DashboardScreen(),
                      gradientColors: [Colors.purple.shade400, Colors.purple.shade700],
                    ),
                    featureCard(
                      context,
                      "Screen Monitoring",
                      "Enable screen time tracking",
                      Icons.phone_android,
                      const UsagePermissionScreen(),
                      gradientColors: [Colors.teal.shade400, Colors.teal.shade700],
                    ),
                    featureCard(
                      context,
                      "Calculation",
                      "View all mathematical computations",
                      Icons.calculate,
                      const CalculationScreen(),
                      gradientColors: [Colors.indigo.shade400, Colors.indigo.shade700],
                    ),
                    featureCard(
                      context,
                      "Factory Reset",
                      "Clear all app data and reset to initial state",
                      Icons.warning_amber_rounded,
                      null,
                      onTap: () => _showResetDialog(context),
                      gradientColors: [Colors.red.shade400, Colors.red.shade700],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
