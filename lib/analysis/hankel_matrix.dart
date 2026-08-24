class HankelMatrix {

  static List<List<double>> buildHankel(List<List<double>> data) {

    int rows = data.length - 2;

    List<List<double>> hankel = [];

    for (int i = 0; i < rows; i++) {

      List<double> row = [];

      row.addAll(data[i]);
      row.addAll(data[i + 1]);
      row.addAll(data[i + 2]);

      hankel.add(row);

    }

    return hankel;
  }

}