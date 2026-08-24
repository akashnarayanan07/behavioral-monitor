import 'dart:math' as math;

class DailyScore {
  static double compute(Map<String, dynamic> data) {
    return computeWithBreakdown(data)['finalScore'];
  }

  static Map<String, dynamic> computeWithBreakdown(Map<String, dynamic> data) {
    double sleep = (data['sleep'] ?? 0.0).toDouble();
    double work = (data['work'] ?? 0.0).toDouble();
    double study = (data['study'] ?? 0.0).toDouble();
    double workout = (data['workout'] ?? 0.0).toDouble();
    int food = data['food'] ?? 1;
    int mealSkipped = data['mealSkipped'] ?? 0;
    int routine = data['routine'] ?? 1;
    double screen = (data['screenTime'] ?? 0.0).toDouble();
    int calls = data['calls'] ?? 0;
    double maxCall = (data['maxCallDuration'] ?? 0.0).toDouble();

    // 1. Sleep: Continuous smooth scoring
    // 0 hours = 0.0, 7-9 hours = 1.0, 12+ hours gradually decreases but never hits hard zero
    double sleepScore;
    if (sleep >= 7.0 && sleep <= 9.0) {
      sleepScore = 1.0;
    } else if (sleep < 7.0) {
      // Linear ramp from 0 to 1 between 0h and 7h
      sleepScore = sleep / 7.0;
    } else {
      // Smooth decay for oversleep using a Gaussian-like curve centered at 9
      // This ensures 12h or 14h still has a reasonable (though lower) score
      sleepScore = math.exp(-math.pow(sleep - 9.0, 2) / 18.0);
    }
    sleepScore = sleepScore.clamp(0.0, 1.0);

    // 2. Productivity: Optimal 6–8h
    double totalProductive = work + study;
    double productiveScore;
    if (totalProductive >= 6.0 && totalProductive <= 8.0) {
      productiveScore = 1.0;
    } else if (totalProductive < 6.0) {
      productiveScore = (totalProductive / 6.0).clamp(0.0, 1.0);
    } else {
      // Smooth decay for overwork
      productiveScore = math.exp(-(totalProductive - 8.0) / 6.0);
    }
    productiveScore = productiveScore.clamp(0.0, 1.0);

    // 3. Workout: 30m+ is 1.0. 0m is 0.0.
    double workoutScore = (workout / 30.0).clamp(0.0, 1.0);

    // 4. Screen Time: Bad metric. Smooth decreasing function.
    // 0-3h = 1.0, then decreases. 12h results in ~0.22 instead of hard 0.
    double screenScore = screen <= 3.0 ? 1.0 : math.exp(-(screen - 3.0) / 6.0);
    screenScore = screenScore.clamp(0.0, 1.0);

    // 5. Food Habit: 3=1.0, 2=0.6, 1=0.2
    double foodScore = (food / 3.0).clamp(0.2, 1.0);

    // 6. Meal Regularity: 0 skipped = 1.0. 3 skipped = 0.2.
    double mealScore = (1.0 - (mealSkipped * 0.26)).clamp(0.2, 1.0);

    // 7. Routine: 1-5 scale mapped to 0.2-1.0
    double routineScoreNormalized = (routine / 5.0).clamp(0.2, 1.0);

    // 8. Social Interaction: 0 interactions = 0.2 baseline. 3-10 interactions = 1.0.
    double phoneScore;
    if (calls >= 3 && calls <= 10) {
      phoneScore = 1.0;
    } else if (calls < 3) {
      phoneScore = 0.2 + (calls / 3.0) * 0.8;
    } else {
      phoneScore = math.exp(-(calls - 10.0) / 15.0);
    }
    phoneScore = phoneScore.clamp(0.2, 1.0);

    // Weighted Scoring
    Map<String, double> weights = {
      'sleep': 0.30,
      'productive': 0.15,
      'workout': 0.10,
      'screen': 0.15,
      'routine': 0.15,
      'meal': 0.05,
      'food': 0.05,
      'phone': 0.05,
    };

    double weightedTotal = (sleepScore * weights['sleep']!) +
        (productiveScore * weights['productive']!) +
        (workoutScore * weights['workout']!) +
        (screenScore * weights['screen']!) +
        (routineScoreNormalized * weights['routine']!) +
        (mealScore * weights['meal']!) +
        (foodScore * weights['food']!) +
        (phoneScore * weights['phone']!);

    // Soft Penalties (Continuous)
    double penaltyMultiplier = 1.0;
    if (sleep < 4.0) penaltyMultiplier *= (0.5 + 0.5 * (sleep / 4.0));
    if (screen > 10.0) penaltyMultiplier *= math.exp(-(screen - 10.0) / 10.0);
    if (routine <= 2) penaltyMultiplier *= 0.8;

    double finalScore = (weightedTotal * penaltyMultiplier * 10.0).clamp(0.0, 10.0);

    return {
      'inputs': data,
      'intermediateScores': {
        'sleepScore': sleepScore,
        'productiveScore': productiveScore,
        'workoutScore': workoutScore,
        'foodScore': foodScore,
        'mealScore': mealScore,
        'routineScore': routineScoreNormalized,
        'screenScore': screenScore,
        'phoneScore': phoneScore,
      },
      'weights': weights,
      'finalScore': finalScore,
    };
  }
}
