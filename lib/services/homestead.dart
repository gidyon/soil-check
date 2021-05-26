import 'package:flutter_app/database.dart';
import 'package:flutter_app/services/soil_result_sqlite.dart';

class HomeSteadService {
  static Future<List<String>> fetchHomesteads(String homeStead) async {
    final db = await DBProvider.db.database;

    var results = await db.query(
      soilCheckResultsTable,
      distinct: true,
      where: homeStead.isNotEmpty ? "homeStead LIKE ?" : null,
      whereArgs: homeStead.isNotEmpty ? [homeStead] : null,
      columns: ["homeStead"],
      limit: 5,
      orderBy: "id DESC",
    );

    return !results.isNotEmpty
        ? []
        : List.generate(results.length, (i) {
            return results[i]["homeStead"];
          });
  }

  static Future<List<String>> fetchZones(String homeStead, String zone) async {
    final db = await DBProvider.db.database;

    String condition = "";
    List<String> args = [];

    if (homeStead.isNotEmpty) {
      condition = "homeStead == ?";
      args = [homeStead];
    }
    if (zone.isNotEmpty) {
      condition += " AND zone LIKE ?";
      args.add(zone);
    }

    var results = await db.query(
      soilCheckResultsTable,
      distinct: true,
      where: condition.isEmpty ? null : condition,
      whereArgs: args.length != 0 ? args : null,
      columns: ["zone"],
      limit: 5,
      orderBy: "id DESC",
    );

    return !results.isNotEmpty
        ? []
        : List.generate(results.length, (i) {
            return results[i]["zone"];
          });
  }
}
