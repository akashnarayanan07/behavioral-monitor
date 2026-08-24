class DMDAnalysis {

  static double computeStability(List<List<double>> hankelData) {

    if (hankelData.length < 2) {
      return 0;
    }

    double totalChange = 0;
    int count = 0;

    for (int i = 0; i < hankelData.length - 1; i++) {

      List<double> current = hankelData[i];
      List<double> next = hankelData[i + 1];

      for (int j = 0; j < current.length; j++) {

        double diff = (next[j] - current[j]).abs();

        totalChange += diff;
        count++;

      }

    }

    double avgChange = totalChange / count;

    return avgChange;

  }

}