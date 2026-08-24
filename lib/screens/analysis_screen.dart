import 'package:flutter/material.dart';
import 'dart:math';
import '../database/database_service.dart';
import '../analysis/daily_score.dart';
import '../analysis/mental_state_service.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> rawData = [];
  List<double> scores = [];
  
  double averageScore = 0;
  double stdDev = 0;
  double trendSlope = 0;
  Map<String, double> mentalState = {};

  @override
  void initState() {
    super.initState();
    _loadAnalysisData();
  }

  Future<void> _loadAnalysisData() async {
    final data = await DatabaseService.getLast10();
    if (data.length >= 5) {
      final chronologicalData = data.reversed.toList();
      List<double> calculatedScores = chronologicalData.map((e) => DailyScore.compute(e)).toList();
      
      // 1. Overall Summary Stats
      averageScore = calculatedScores.reduce((a, b) => a + b) / calculatedScores.length;
      double variance = calculatedScores.map((x) => pow(x - averageScore, 2)).reduce((a, b) => a + b) / calculatedScores.length;
      stdDev = sqrt(variance);
      
      // Trend Slope (Simple linear regression approximation)
      trendSlope = (calculatedScores.last - calculatedScores.first) / (calculatedScores.length - 1);

      // 2. Mental State (based on latest entry)
      mentalState = MentalStateService.computeMentalState(data.first);

      setState(() {
        rawData = data;
        scores = calculatedScores;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _getTrendText() {
    if (trendSlope > 0.15) return "Improving";
    if (trendSlope < -0.15) return "Declining";
    return "Stable";
  }

  String _getConsistencyText() {
    if (stdDev < 0.8) return "High Consistency";
    if (stdDev < 1.5) return "Moderate Variability";
    return "High Fluctuation";
  }

  Widget _buildReportSection(String title, IconData icon, Color color, Widget content) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 10),
                Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const Divider(height: 24),
            content,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Comprehensive Analysis")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : rawData.length < 5
              ? const Center(child: Text("Insufficient data for detailed analysis"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildReportSection(
                        "Overall Summary",
                        Icons.summarize,
                        Colors.blue,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _infoRow("Average Stability:", "${averageScore.toStringAsFixed(1)} / 10"),
                            _infoRow("Trend Path:", _getTrendText()),
                            _infoRow("Consistency:", _getConsistencyText()),
                          ],
                        ),
                      ),
                      _buildReportSection(
                        "Mental Health Markers",
                        Icons.psychology,
                        Colors.purple,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: mentalState.entries.map((e) => _infoRow("${e.key}:", "${e.value.toStringAsFixed(0)}% (${MentalStateService.getLevel(e.value)})")).toList(),
                        ),
                      ),
                      _buildReportSection(
                        "Clinical Interpretation",
                        Icons.medical_services,
                        Colors.teal,
                        Text(
                          _generateClinicalObservation(),
                          style: const TextStyle(fontSize: 14, height: 1.5),
                        ),
                      ),
                      _buildReportSection(
                        "Recommendations",
                        Icons.assignment,
                        Colors.orange,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Prescribed Lifestyle Adjustments:", style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            ..._getRecommendations().map((r) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("• ", style: TextStyle(fontWeight: FontWeight.bold)),
                                  Expanded(child: Text(r)),
                                ],
                              ),
                            )),
                            if (averageScore < 4 || mentalState.values.any((v) => v > 70))
                              const Padding(
                                padding: EdgeInsets.only(top: 15),
                                child: Text(
                                  "⚠️ Professional consultation is recommended due to detected high-risk patterns.",
                                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _generateClinicalObservation() {
    String trend = _getTrendText().toLowerCase();
    String obs = "The patient's behavioral architecture over the last ${rawData.length} observations reflects $trend dynamics with ${_getConsistencyText().toLowerCase()}. ";
    
    if (averageScore >= 7) {
      obs += "This indicates robust self-regulation and a resilient daily structure. ";
    } else if (averageScore >= 4) {
      obs += "The system shows moderate regulation with some susceptibility to lifestyle stressors. ";
    } else {
      obs += "The data signifies significant behavioral dysregulation. ";
    }

    if (mentalState['Stress']! > 60) {
      obs += "Physiological stress markers are elevated, likely correlated with sleep hygiene deviations or excessive cognitive load (screen time). ";
    }
    
    return obs;
  }

  List<String> _getRecommendations() {
    List<String> recs = [];
    final latest = rawData.first;
    
    if ((latest['sleep'] ?? 0) < 7) recs.add("Increase sleep duration to 7-8 hours consistently.");
    if ((latest['screenTime'] ?? 0) > 6) recs.add("Reduce digital exposure, especially 1 hour before sleep.");
    if ((latest['workout'] ?? 0) < 30) recs.add("Integrate at least 30 minutes of moderate physical activity.");
    if ((latest['routine'] ?? 3) < 4) recs.add("Enhance routine structure to improve circadian rhythm stability.");
    if (recs.isEmpty) recs.add("Maintain current healthy behavioral patterns.");
    
    return recs;
  }
}
