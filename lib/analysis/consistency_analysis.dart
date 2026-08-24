class ConsistencyAnalysis {

  static double computeConsistency(List<List<double>> dataset) {

    if (dataset.length < 2) return 100;

    double totalDiff = 0;
    int count = 0;

    for (int i = 1; i < dataset.length; i++) {

      for (int j = 0; j < dataset[i].length; j++) {

        totalDiff += (dataset[i][j] - dataset[i - 1][j]).abs();
        count++;

      }

    }

    double avgDiff = totalDiff / count;

    double score = 100 - (avgDiff * 10);

    if (score < 0) score = 0;
    if (score > 100) score = 100;

    return score;
  }

}