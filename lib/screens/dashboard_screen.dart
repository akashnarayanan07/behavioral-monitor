import 'package:flutter/material.dart';
import 'daily_stability_screen.dart';
import 'mental_health_screen.dart';
import 'graph_screen.dart';
import 'mental_state_graph_screen.dart';
import 'analysis_screen.dart';
import '../database/database_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int entryCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntryCount();
  }

  Future<void> _loadEntryCount() async {
    final data = await DatabaseService.getLast10();
    setState(() {
      entryCount = data.length;
      isLoading = false;
    });
  }

  Widget dashboardCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Widget page, {
    bool enabled = true,
    String disabledSubtitle = "",
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      elevation: enabled ? 4 : 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          leading: Icon(icon, size: 40, color: enabled ? Colors.blueAccent : Colors.grey),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: enabled ? Colors.black87 : Colors.grey,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              enabled ? subtitle : disabledSubtitle,
              style: TextStyle(color: enabled ? Colors.grey[600] : Colors.grey[400]),
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: enabled ? Colors.blueAccent : Colors.grey[300],
            size: 18,
          ),
          onTap: enabled
              ? () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => page));
                }
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stability Dashboard"),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  dashboardCard(
                    context,
                    "Daily Stability Score",
                    "View daily behavior-based score and insights",
                    Icons.today,
                    const DailyStabilityScreen(),
                  ),
                  dashboardCard(
                    context,
                    "Mental Health Tracking",
                    "Advanced analysis using matrix and system modeling",
                    Icons.analytics_outlined,
                    const MentalHealthScreen(),
                  ),
                  dashboardCard(
                    context,
                    "Stability Graph",
                    "Professional trend visualization",
                    Icons.show_chart,
                    const GraphScreen(graphPoints: []),
                  ),
                  dashboardCard(
                    context,
                    "Mental State Analysis",
                    "View stress, anxiety, and depression levels",
                    Icons.psychology,
                    const MentalStateGraphScreen(),
                  ),
                  dashboardCard(
                    context,
                    "Analysis",
                    "View comprehensive behavioral summary and recommendations",
                    Icons.assessment_outlined,
                    const AnalysisScreen(),
                    enabled: entryCount >= 5,
                    disabledSubtitle: "Available after 5 days of data",
                  ),
                ],
              ),
            ),
    );
  }
}
