import 'package:flutter/material.dart';
import '../database/database_service.dart';
import '../analysis/hankel_matrix.dart';
import '../analysis/dmd_analysis.dart';
import '../analysis/daily_score.dart';
import 'dart:async';
import 'dart:math' as math;

class MentalHealthScreen extends StatefulWidget {
  const MentalHealthScreen({super.key});

  @override
  State<MentalHealthScreen> createState() => _MentalHealthScreenState();
}

class _MentalHealthScreenState extends State<MentalHealthScreen> with SingleTickerProviderStateMixin {
  double stabilityScore = 0;
  bool isLoading = true;
  late AnimationController _blinkController;
  List<double> combinedSeries = [];

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _loadAdvancedAnalysis();
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  Future<void> _loadAdvancedAnalysis() async {
    final data = await DatabaseService.getLast10();
    List<double> scores = [];
    double finalMhScore = 0;

    if (data.isNotEmpty) {
      scores = data.reversed.map((entry) => DailyScore.compute(entry)).toList();

      if (scores.length >= 3) {
        // 1. Calculate Statistics for Outlier Detection
        double mean = scores.reduce((a, b) => a + b) / scores.length;
        double variance = scores.map((x) => math.pow(x - mean, 2)).reduce((a, b) => a + b) / scores.length;
        double stdDev = math.sqrt(variance);

        // 2. Identify and Dampen Outliers (using 1.5 sigma threshold)
        List<double> dampenedScores = scores.map((s) {
          if ((s - mean).abs() > 1.5 * stdDev) {
            // Outlier detected: pull it closer to the mean
            return mean + (s - mean) * 0.3;
          }
          return s;
        }).toList();

        // 3. Weighted Temporal Averaging (Recent days have higher impact)
        int n = dampenedScores.length;
        double weightedSum = 0;
        double weightTotal = 0;
        
        for (int i = 0; i < n; i++) {
          double weight = math.pow(1.5, i).toDouble(); // exponential decay for older days
          weightedSum += dampenedScores[i] * weight;
          weightTotal += weight;
        }
        double temporalAvg = weightedSum / weightTotal;

        // 4. Stability Factor based on Variance
        // Higher variance = lower stability factor
        double stabilityFactor = math.exp(-stdDev / 4.0);

        // 5. Final Score Calculation with Trend Factor
        double latest = dampenedScores.last;
        double previous = dampenedScores[n - 2];
        double trend = (latest - previous) * 0.2; // trend influence

        finalMhScore = (temporalAvg * 0.7 + latest * 0.2 + trend) * stabilityFactor;
        finalMhScore = finalMhScore.clamp(0.0, 10.0);

        double speedFactor = (11 - finalMhScore).clamp(1, 10);
        _blinkController.duration = Duration(milliseconds: (1000 / speedFactor).round());
        _blinkController.repeat(reverse: true);
      } else {
        _blinkController.stop();
        _blinkController.value = 1.0; 
      }
    } else {
      _blinkController.stop();
      _blinkController.value = 1.0;
    }

    setState(() {
      stabilityScore = finalMhScore;
      combinedSeries = scores;
      isLoading = false;
    });
  }

  Color _getStatusColor() {
    if (combinedSeries.length < 3) return Colors.blueGrey;
    if (stabilityScore >= 7.0) return Colors.green;
    if (stabilityScore >= 4.5) return Colors.yellow;
    return Colors.red;
  }

  String _getStatusText() {
    if (combinedSeries.isEmpty) return "No Data Available";
    if (combinedSeries.length < 3) return "Insufficient Data";
    if (stabilityScore >= 7.0) return "Healthy";
    if (stabilityScore >= 4.5) return "Moderate";
    return "Risk/Danger";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mental Health Tracking")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Advanced Mental Stability Score",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "(Temporal Variance & Outlier Detection)",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  
                  FadeTransition(
                    opacity: _blinkController,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getStatusColor(),
                        boxShadow: [
                          BoxShadow(
                            color: _getStatusColor().withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 10,
                          )
                        ],
                      ),
                      child: const Icon(Icons.lightbulb, color: Colors.white, size: 40),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  Text(
                    combinedSeries.length < 3 ? "--" : stabilityScore.toStringAsFixed(1),
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: _getStatusColor()),
                  ),
                  Text(
                    _getStatusText(),
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: _getStatusColor()),
                  ),
                  
                  const SizedBox(height: 40),

                  if (combinedSeries.length >= 3) ...[
                    _buildInfoCard(
                      "Longitudinal Analysis",
                      "The system utilizes statistical outlier detection and weighted temporal averaging to identify your true behavioral baseline. This prevents single-day anomalies from incorrectly triggering a high-risk warning.",
                      Icons.insights,
                    ),
                    
                    _buildInfoCard(
                      "Clinical Insight",
                      stabilityScore < 4.5 
                        ? "Significant behavioral dysregulation detected. High pattern variance or persistent low stability markers indicate a potentially unstable psychological state."
                        : "Your behavioral pattern reflects structural resilience. Continuity in healthy habits across the observed timeline is supporting a stable mental state.",
                      Icons.analytics_outlined,
                    ),
                    
                    if (stabilityScore < 3.5)
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.warning, color: Colors.red),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "⚠️ ALERT: Critical instability detected based on sustained behavioral decline. Please prioritize rest and consider professional consultation.",
                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ] else ...[
                    _buildInfoCard(
                      "Analysis Status",
                      combinedSeries.isEmpty 
                          ? "No behavior data tracked yet."
                          : "Insufficient data for longitudinal analysis. Log at least 3 days to establish a baseline stability index.",
                      Icons.info_outline,
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blueAccent),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(),
            Text(content, style: const TextStyle(fontSize: 15, height: 1.4)),
          ],
        ),
      ),
    );
  }
}
