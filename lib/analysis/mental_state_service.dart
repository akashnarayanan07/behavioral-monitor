import 'daily_score.dart';

class MentalStateService {
  /// Computes Stress, Anxiety, and Depression levels (0-100)
  /// based on 10 behavioral attributes.
  static Map<String, double> computeMentalState(Map<String, dynamic> data) {
    try {
      final breakdown = DailyScore.computeWithBreakdown(data);
      final scores = breakdown['intermediateScores'] as Map<String, dynamic>? ?? {};
      final inputs = (breakdown['inputs'] as Map<String, dynamic>?) ?? data;

      // 1. Stress Score (0-100)
      double stress = 0;
      stress += (1.0 - (scores['sleepScore'] ?? 0.0)) * 30;
      stress += (1.0 - (scores['screenScore'] ?? 0.0)) * 25;
      stress += (1.0 - (scores['productiveScore'] ?? 0.0)) * 20;
      stress += (1.0 - (scores['routineScore'] ?? 0.0)) * 25;
      
      // 2. Anxiety Score (0-100)
      double anxiety = 0;
      anxiety += (1.0 - (scores['screenScore'] ?? 0.0)) * 35;
      anxiety += (1.0 - (scores['routineScore'] ?? 0.0)) * 30;
      anxiety += (1.0 - (scores['phoneScore'] ?? 0.0)) * 35;

      // 3. Depression Score (0-100)
      double depression = 0;
      depression += (1.0 - (scores['workoutScore'] ?? 0.0)) * 30;
      depression += (1.0 - (scores['foodScore'] ?? 0.0)) * 20;
      depression += (1.0 - (scores['mealScore'] ?? 0.0)) * 25;
      
      double phone = ((inputs['calls'] ?? 0) as num).toDouble() / 10.0;
      double socialWithdrawal = (1.0 - phone).clamp(0.0, 1.0);
      depression += socialWithdrawal * 25;

      return {
        'Stress': stress.clamp(0.0, 100.0),
        'Anxiety': anxiety.clamp(0.0, 100.0),
        'Depression': depression.clamp(0.0, 100.0),
      };
    } catch (e) {
      return {
        'Stress': 0.0,
        'Anxiety': 0.0,
        'Depression': 0.0,
      };
    }
  }

  static String getLevel(double score) {
    if (score <= 20) return "Normal";
    if (score <= 40) return "Mild";
    if (score <= 60) return "Moderate";
    if (score <= 80) return "Severe";
    return "Extremely Severe";
  }
}
