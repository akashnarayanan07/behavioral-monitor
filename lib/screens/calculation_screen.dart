import 'package:flutter/material.dart';
import 'daily_calculation_screen.dart';
import 'mental_calculation_screen.dart';

class CalculationScreen extends StatelessWidget {
  const CalculationScreen({super.key});

  Widget calculationOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Widget page,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        leading: Icon(icon, size: 40, color: Colors.blueAccent),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calculation Details"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            calculationOption(
              context,
              "Daily Stability Calculation",
              "View how daily score is computed from attributes",
              Icons.today,
              const DailyCalculationScreen(),
            ),
            calculationOption(
              context,
              "Mental Health Calculation",
              "View advanced analysis using Hankel matrix and DMD",
              Icons.analytics_outlined,
              const MentalCalculationScreen(),
            ),
          ],
        ),
      ),
    );
  }
}
