class Matrix {

  final List<List<double>> data;

  Matrix(this.data);

  int get rows => data.length;

  int get cols => data.isNotEmpty ? data[0].length : 0;

}