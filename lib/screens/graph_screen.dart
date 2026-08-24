import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import '../database/database_service.dart';
import '../analysis/daily_score.dart';

class GraphScreen extends StatefulWidget {
  final List<FlSpot>? graphPoints;

  const GraphScreen({super.key, this.graphPoints});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  List<FlSpot> points = [];
  List<FlSpot> trendLinePoints = [];
  List<double> stdDevValues = [];
  bool isLoading = true;

  double mean = 0;
  double stdDev = 0;
  double trendSlope = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await DatabaseService.getLast10();
    final chronologicalData = data.reversed.toList();
    
    List<FlSpot> loadedPoints = [];
    for (int i = 0; i < chronologicalData.length; i++) {
      final entry = chronologicalData[i];
      double score = DailyScore.compute(entry);
      loadedPoints.add(FlSpot(i.toDouble(), score));
    }

    if (loadedPoints.length >= 2) {
      // 3. Variability Analysis
      List<double> scores = loadedPoints.map((p) => p.y).toList();
      mean = scores.reduce((a, b) => a + b) / scores.length;
      double variance = scores.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) / scores.length;
      stdDev = sqrt(variance);

      // Trend Line (3-day SMA) and Trend Slope
      List<FlSpot> trendPoints = [];
      for (int i = 0; i < loadedPoints.length; i++) {
        double sum = 0;
        int count = 0;
        for (int j = i - 2; j <= i; j++) {
          if (j >= 0) {
            sum += loadedPoints[j].y;
            count++;
          }
        }
        trendPoints.add(FlSpot(i.toDouble(), sum / count));
      }

      if (trendPoints.length >= 2) {
        trendSlope = (trendPoints.last.y - trendPoints.first.y) / (trendPoints.length - 1);
      }
      
      trendLinePoints = trendPoints;
    }

    setState(() {
      points = loadedPoints;
      isLoading = false;
    });
  }

  String _generateClinicalReport() {
    if (points.length < 5) {
      return "Insufficient data for clinical trend analysis. A minimum of 5 longitudinal observations is required to establish a reliable behavioral trajectory.";
    }

    String trendDescription = trendSlope > 0.1 
        ? "an upward (improving) stability trajectory" 
        : trendSlope < -0.1 
            ? "a downward (declining) stability trajectory" 
            : "a relatively stable baseline";

    String consistency = stdDev > 1.5 
        ? "significant behavioral variability" 
        : "high consistency";

    bool hasSuddenDrop = false;
    for (int i = 1; i < points.length; i++) {
      if (points[i-1].y - points[i].y > 2.5) {
        hasSuddenDrop = true;
        break;
      }
    }

    String riskLevel = "LOW";
    if (mean < 4 || trendSlope < -0.2 || (stdDev > 2.0 && mean < 6)) {
      riskLevel = "HIGH";
    } else if (mean < 6 || trendSlope < -0.05 || stdDev > 1.2) {
      riskLevel = "MODERATE";
    }

    String report = "Clinical Observation:\n";
    report += "The longitudinal assessment indicates $trendDescription. ";
    report += "Analysis of standard deviation (σ = ${stdDev.toStringAsFixed(2)}) reflects $consistency. ";
    if (hasSuddenDrop) {
      report += "Observation reveals acute pattern deviations (sudden drops) which may signify transient stressors or sleep disruptions. ";
    }

    report += "\n\nInterpretation:\n";
    if (riskLevel == "HIGH") {
      report += "The observed data signifies critical behavioral instability. Such a trajectory is frequently correlated with severe sleep deprivation, routine fragmentation, or excessive digital exposure, potentially impacting mental resilience.";
    } else if (riskLevel == "MODERATE") {
      report += "The data suggests moderate fluctuation in behavioral regulation. While not critical, the current variability indicates potential for further destabilization if routine adherence is not prioritized.";
    } else {
      report += "The patient demonstrates resilient behavioral regulation. The stability path is consistent with healthy sleep hygiene and structured daily habits.";
    }

    report += "\n\nRisk Assessment: $riskLevel RISK\n";
    if (riskLevel != "LOW") {
      report += "⚠️ Pattern indicates potential behavioral instability. Monitoring and targeted intervention recommended.";
    }

    return report;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stability Trend Analysis"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : points.isEmpty
              ? const Center(child: Text("No clinical data available"))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Behavioral Stability Index",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          "Longitudinal monitoring of behavioral trajectory",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 30),
                        
                        SizedBox(
                          height: 350,
                          child: LineChart(
                            LineChartData(
                              minY: 0,
                              maxY: 10,
                              minX: 0,
                              maxX: points.length.toDouble() - 1,
                              lineTouchData: LineTouchData(
                                touchTooltipData: LineTouchTooltipData(
                                  tooltipBgColor: Colors.blueGrey.withOpacity(0.9),
                                  getTooltipItems: (touchedSpots) {
                                    return touchedSpots.map((spot) {
                                      final isTrend = spot.barIndex == 1;
                                      return LineTooltipItem(
                                        '${isTrend ? "Trend" : "Score"}: ${spot.y.toStringAsFixed(2)}',
                                        TextStyle(
                                          color: isTrend ? Colors.orangeAccent : Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    }).toList();
                                  },
                                ),
                              ),
                              gridData: const FlGridData(show: true, drawVerticalLine: false),
                              titlesData: FlTitlesData(
                                show: true,
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  axisNameWidget: const Text("Timeline (Days)", style: TextStyle(fontSize: 12)),
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 1,
                                    getTitlesWidget: (value, meta) => Text(
                                      "T-${(points.length - 1 - value.toInt())}",
                                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                                    ),
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  axisNameWidget: const Text("Score", style: TextStyle(fontSize: 12)),
                                  sideTitles: const SideTitles(showTitles: true, interval: 2, reservedSize: 30),
                                ),
                              ),
                              rangeAnnotations: RangeAnnotations(
                                horizontalRangeAnnotations: [
                                  HorizontalRangeAnnotation(y1: 0, y2: 3, color: Colors.red.withOpacity(0.05)),
                                  HorizontalRangeAnnotation(y1: 3, y2: 7, color: Colors.orange.withOpacity(0.05)),
                                  HorizontalRangeAnnotation(y1: 7, y2: 10, color: Colors.green.withOpacity(0.05)),
                                ],
                              ),
                              borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.withOpacity(0.2))),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: points,
                                  isCurved: true,
                                  barWidth: 3,
                                  gradient: const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter: (spot, percent, barData, index) {
                                      bool isAnomaly = index > 0 && (points[index-1].y - spot.y).abs() > 2.5;
                                      return FlDotCirclePainter(
                                        radius: isAnomaly ? 6 : 4,
                                        color: isAnomaly ? Colors.red : Colors.blue,
                                        strokeWidth: 2,
                                        strokeColor: Colors.white,
                                      );
                                    },
                                  ),
                                ),
                                if (trendLinePoints.isNotEmpty)
                                  LineChartBarData(
                                    spots: trendLinePoints,
                                    isCurved: true,
                                    barWidth: 2,
                                    color: Colors.orange.withOpacity(0.6),
                                    dotData: const FlDotData(show: false),
                                    dashArray: [5, 5],
                                  ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        _buildLegend(),
                        
                        const SizedBox(height: 40),
                        _buildClinicalReportCard(),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildLegend() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legendItem(Colors.blue, "Stability Index"),
            const SizedBox(width: 20),
            _legendItem(Colors.orange.withOpacity(0.6), "Trend Line (SMA)", isDash: true),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legendItem(Colors.green.withOpacity(0.2), "Healthy"),
            const SizedBox(width: 10),
            _legendItem(Colors.orange.withOpacity(0.2), "Moderate"),
            const SizedBox(width: 10),
            _legendItem(Colors.red.withOpacity(0.2), "High Risk"),
          ],
        ),
      ],
    );
  }

  Widget _legendItem(Color color, String label, {bool isDash = false}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: isDash ? null : color,
            borderRadius: BorderRadius.circular(2),
          ),
          child: isDash ? const Center(child: Text("- - -", style: TextStyle(color: Colors.orange, fontSize: 8, fontWeight: FontWeight.bold))) : null,
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.black87)),
      ],
    );
  }

  Widget _buildClinicalReportCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blueGrey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.assignment_ind, color: Colors.blueGrey, size: 24),
              SizedBox(width: 10),
              Text(
                "Clinical Observation Report",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
              ),
            ],
          ),
          const Divider(height: 25),
          Text(
            _generateClinicalReport(),
            style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.6),
          ),
          const SizedBox(height: 20),
          const Text(
            "* This report is generated based on automated behavioral monitoring and is intended for informational reference only.",
            style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
