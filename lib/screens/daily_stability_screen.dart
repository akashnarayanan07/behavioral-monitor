import 'package:flutter/material.dart';
import '../database/database_service.dart';
import '../analysis/daily_score.dart';

class DailyStabilityScreen extends StatefulWidget {
  const DailyStabilityScreen({super.key});

  @override
  State<DailyStabilityScreen> createState() => _DailyStabilityScreenState();
}

class _DailyStabilityScreenState extends State<DailyStabilityScreen> {
  List<Map<String, dynamic>> dailyData = [];
  bool isLoading = true;
  bool isReversed = false; // Default: Newest First (DESC from DB)

  @override
  void initState() {
    super.initState();
    _loadDailyData();
  }

  Future<void> _loadDailyData() async {
    final data = await DatabaseService.getLast10();
    setState(() {
      dailyData = data;
      isLoading = false;
    });
  }

  Color _getScoreColor(double score) {
    if (score >= 7) return Colors.green;
    if (score >= 4) return Colors.orange;
    return Colors.red;
  }

  String _getAIInsights(Map<String, dynamic> entry) {
    List<String> insights = [];
    double sleep = (entry['sleep'] ?? 0).toDouble();
    double screen = (entry['screenTime'] ?? 0).toDouble();
    int skipped = entry['mealSkipped'] ?? 0;

    if (sleep < 7) insights.add("Inadequate sleep");
    if (screen > 6) insights.add("high screen usage");
    if (skipped > 0) insights.add("missing meals");

    if (insights.isEmpty) return "Your behaviors are well-balanced and supporting stability.";
    
    String message = "${insights.join(" and ")} impacted your daily score.";
    return message[0].toUpperCase() + message.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    // Determine the display order based on isReversed toggle
    List<Map<String, dynamic>> displayData = isReversed 
        ? dailyData.reversed.toList() 
        : dailyData;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Stability Score"),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_vert),
            tooltip: isReversed ? "Newest First" : "Oldest First",
            onPressed: () {
              setState(() {
                isReversed = !isReversed;
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : dailyData.isEmpty
              ? const Center(child: Text("No data available"))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "Showing: ${isReversed ? "Oldest First" : "Newest First"}",
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: displayData.length,
                        itemBuilder: (context, index) {
                          final entry = displayData[index];
                          final score = DailyScore.compute(entry);
                          final color = _getScoreColor(score);
                          
                          // Determine actual index for labeling if date is missing
                          int displayIndex = isReversed ? index + 1 : dailyData.length - index;
                          final date = entry['date'] ?? "Entry $displayIndex";

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: color),
                                        ),
                                        child: Text(
                                          score.toStringAsFixed(1),
                                          style: TextStyle(color: color, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  const Text("AI Analysis:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text(_getAIInsights(entry), style: const TextStyle(fontSize: 14, color: Colors.black87)),
                                  const SizedBox(height: 8),
                                  const Text("Suggestions:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue)),
                                  const Text("• Maintain 7-8h sleep\n• Control digital exposure\n• Stick to meal times", style: TextStyle(fontSize: 13, height: 1.5)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
