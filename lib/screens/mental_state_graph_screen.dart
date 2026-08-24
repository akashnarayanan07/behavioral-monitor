import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../database/database_service.dart';
import '../analysis/mental_state_service.dart';

class MentalStateGraphScreen extends StatefulWidget {
  const MentalStateGraphScreen({super.key});

  @override
  State<MentalStateGraphScreen> createState() => _MentalStateGraphScreenState();
}

class _MentalStateGraphScreenState extends State<MentalStateGraphScreen> {
  Map<String, double>? mentalStateScores;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await DatabaseService.getLast10();
    if (data.isNotEmpty) {
      final scores = MentalStateService.computeMentalState(data.first);
      setState(() {
        mentalStateScores = scores;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Color _getBarColor(double score) {
    if (score <= 40) return Colors.green;
    if (score <= 70) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mental State Analysis")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : mentalStateScores == null
              ? const Center(child: Text("No data available for analysis"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        "Stress, Anxiety & Depression Levels",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 30),
                      
                      AspectRatio(
                        aspectRatio: 1.2,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: 100,
                            barTouchData: BarTouchData(enabled: true),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 12);
                                    switch (value.toInt()) {
                                      case 0: return const Text('Stress', style: style);
                                      case 1: return const Text('Anxiety', style: style);
                                      case 2: return const Text('Depression', style: style);
                                      default: return const Text('');
                                    }
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  getTitlesWidget: (value, meta) => Text("${value.toInt()}%", style: const TextStyle(fontSize: 10)),
                                ),
                              ),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 20),
                            borderData: FlBorderData(show: false),
                            barGroups: [
                              _makeBarGroup(0, mentalStateScores!['Stress']!),
                              _makeBarGroup(1, mentalStateScores!['Anxiety']!),
                              _makeBarGroup(2, mentalStateScores!['Depression']!),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildLevelLabel("Stress", mentalStateScores!['Stress']!),
                          _buildLevelLabel("Anxiety", mentalStateScores!['Anxiety']!),
                          _buildLevelLabel("Depression", mentalStateScores!['Depression']!),
                        ],
                      ),
                      
                      const SizedBox(height: 40),
                      _buildInterpretationCard(),
                    ],
                  ),
                ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: _getBarColor(y),
          width: 40,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          backDrawRodData: BackgroundBarChartRodData(show: true, toY: 100, color: Colors.grey[200]),
        ),
      ],
    );
  }

  Widget _buildLevelLabel(String title, double score) {
    String level = MentalStateService.getLevel(score);
    return Column(
      children: [
        Text(level, style: TextStyle(fontWeight: FontWeight.bold, color: _getBarColor(score), fontSize: 13)),
      ],
    );
  }

  Widget _buildInterpretationCard() {
    double stress = mentalStateScores!['Stress']!;
    double anxiety = mentalStateScores!['Anxiety']!;
    double depression = mentalStateScores!['Depression']!;
    
    bool isHigh = stress > 60 || anxiety > 60 || depression > 60;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.psychology, color: Colors.blueAccent),
                SizedBox(width: 10),
                Text("AI Interpretation", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(),
            const Text(
              "Based on your behavioral markers (Sleep, Screen usage, Routine, and Activity), the system estimates your psychological load.",
              style: TextStyle(height: 1.5),
            ),
            const SizedBox(height: 10),
            if (isHigh)
              const Text(
                "⚠️ Warning: Your behavioral pattern indicates elevated stress/anxiety levels. This is often linked to irregular sleep cycles and high digital exposure. Consider lifestyle adjustments or professional consultation.",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, height: 1.5),
              )
            else
              const Text(
                "Your current behavioral patterns reflect a relatively stable mental state. Maintaining a consistent routine and regular physical activity will help preserve this balance.",
                style: TextStyle(height: 1.5),
              ),
            const SizedBox(height: 15),
            const Text("Suggestions for improvement:", style: TextStyle(fontWeight: FontWeight.bold)),
            const Text("• Ensure 7-8 hours of consistent sleep."),
            const Text("• Reduce screen exposure during rest periods."),
            const Text("• Maintain a structured daily routine."),
            const Text("• Engage in at least 30 mins of physical activity."),
          ],
        ),
      ),
    );
  }
}
