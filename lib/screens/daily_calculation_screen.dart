import 'package:flutter/material.dart';
import '../database/database_service.dart';
import '../analysis/daily_score.dart';

class DailyCalculationScreen extends StatefulWidget {
  const DailyCalculationScreen({super.key});

  @override
  State<DailyCalculationScreen> createState() => _DailyCalculationScreenState();
}

class _DailyCalculationScreenState extends State<DailyCalculationScreen> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? latestBreakdown;
  bool isLoading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final data = await DatabaseService.getLast10();
    if (data.isNotEmpty) {
      final breakdown = DailyScore.computeWithBreakdown(data.first);
      setState(() {
        latestBreakdown = breakdown;
        isLoading = false;
      });
      _animationController.forward();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildSection(String title, IconData icon, Color color, Widget content) {
    return FadeTransition(
      opacity: _animationController,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: content,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Daily Calculation"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : latestBreakdown == null
              ? const Center(child: Text("No data available"))
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      _buildSection(
                        "Raw Input Data",
                        Icons.input,
                        Colors.blue,
                        _buildRawInputVisuals(latestBreakdown!['inputs']),
                      ),
                      _buildSection(
                        "Normalization (0-1 Scale)",
                        Icons.bar_chart,
                        Colors.teal,
                        _buildNormalizationVisuals(latestBreakdown!['intermediateScores']),
                      ),
                      _buildSection(
                        "Weighted Contributions",
                        Icons.functions,
                        Colors.purple,
                        _buildWeightedContributions(latestBreakdown!),
                      ),
                      _buildSection(
                        "Final Stability Score",
                        Icons.check_circle,
                        Colors.green,
                        _buildFinalScoreVisual(latestBreakdown!['finalScore']),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
    );
  }

  Widget _buildRawInputVisuals(Map<String, dynamic> data) {
    final List<Map<String, dynamic>> items = [
      {'label': 'Sleep', 'value': '${data['sleep']}h', 'icon': '💤'},
      {'label': 'Work', 'value': '${data['work']}h', 'icon': '💼'},
      {'label': 'Study', 'value': '${data['study']}h', 'icon': '📚'},
      {'label': 'Workout', 'value': '${data['workout']}m', 'icon': '🏃'},
      {'label': 'Screen', 'value': '${data['screenTime']}h', 'icon': '📱'},
      {'label': 'Calls', 'value': '${data['calls']}', 'icon': '📞'},
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((item) {
        return Container(
          width: 100,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              Text(item['icon'], style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 5),
              Text(item['label'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(item['value'], style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ).animateClick();
      }).toList(),
    );
  }

  Widget _buildNormalizationVisuals(Map<String, dynamic> scores) {
    return Column(
      children: scores.entries.map((entry) {
        double val = entry.value.toDouble();
        Color color = val > 0.7 ? Colors.green : (val > 0.4 ? Colors.orange : Colors.red);
        String label = entry.key.replaceAll('Score', '').toUpperCase();
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  Text("${(val * 100).toInt()}%", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: val,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWeightedContributions(Map<String, dynamic> breakdown) {
    final weights = Map<String, double>.from(breakdown['weights'] ?? {});
    final scores = breakdown['intermediateScores'] as Map<String, dynamic>;

    return Column(
      children: weights.entries.map((entry) {
        String key = entry.key;
        double weight = entry.value;
        double score = scores['${key == "productive" ? "productive" : key == "phone" ? "phone" : key}Score'] ?? 0.0;
        double contribution = score * weight;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(key.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              Expanded(
                flex: 5,
                child: Text(
                  "${score.toStringAsFixed(2)} × $weight",
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ),
              Text(
                "+${contribution.toStringAsFixed(3)}",
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFinalScoreVisual(double score) {
    Color color = score >= 7 ? Colors.green : (score >= 4 ? Colors.orange : Colors.red);
    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: score / 10,
                  strokeWidth: 10,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Text(
                score.toStringAsFixed(1),
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              score >= 7 ? "HIGH STABILITY" : (score >= 4 ? "MODERATE STABILITY" : "LOW STABILITY"),
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

extension on Widget {
  Widget animateClick() => this; // Placeholder for potential animation wrapper
}
