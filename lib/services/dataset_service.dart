import '../database/database_service.dart';

class DatasetService {

  static Future<List<List<double>>> getDataset() async {

    final db = await DatabaseService.database;

    List<Map<String, dynamic>> rows =
    await db.query('behavior');

    List<List<double>> dataset = [];

    for (var row in rows) {

      dataset.add([
        (row['sleep'] ?? 0).toDouble(),
        (row['work'] ?? 0).toDouble(),
        (row['study'] ?? 0).toDouble(),
        (row['workout'] ?? 0).toDouble(),
        (row['food'] ?? 0).toDouble(),
        (row['mealSkipped'] ?? 0).toDouble(),
        (row['routine'] ?? 0).toDouble(),
        (row['screen'] ?? 0).toDouble(),
        (row['calls'] ?? 0).toDouble(),
        (row['maxcall'] ?? 0).toDouble(),
        (row['mood'] ?? 0).toDouble(),
      ]);

    }
    if (dataset.length > 10) {
      dataset = dataset.sublist(dataset.length - 10);
    }

    return dataset;

  }

}