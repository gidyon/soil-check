import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "store.db");
    return await openDatabase(path, version: 15, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE SoilCheckResults ("
          "id INTEGER PRIMARY KEY,"
          "timestamp INTEGER not null,"
          "ownerPhone TEXT not null,"
          "homeStead TEXT not null,"
          "zone TEXT not null,"
          "notes TEXT,"
          "longitude REAL not null,"
          "latitude REAL not null,"
          "testType TEXT not null,"
          "label TEXT not null,"
          "confidence REAL not null,"
          "resultsReady INTEGER not null,"
          "resultSynced INTEGER not null,"
          "resultDescription TEXT not null,"
          "resultStatus TEXT not null,"
          "imageBase64 TEXT not null,"
          "imageUrl TEXT,"
          "modelResults TEXT not null,"
          "recommendations TEXT"
          ")");
      await db.execute("CREATE TABLE Account ("
          "id INTEGER PRIMARY KEY,"
          "names TEXT not null,"
          "phone TEXT not null,"
          "language TEXT not null"
          ")");
    });
  }

  // addUser(UserModel newUser) async {
  //   final db = await database;
  //   var res = await db.insert("User", newUser.toMap());
  //   return res;
  // }

  // deleteAllUsers() async {
  //   final db = await database;
  //   await db.rawDelete("Delete from User");
  // }

  // updateClient(UserModel user) async {
  //   final db = await database;
  //   var res = await db.update("User", user.toMap(),
  //       where: "msisdn = ?", whereArgs: [user.msisdn]);
  //   return res;
  // }

  // Future<UserModel> getActiveClient() async {
  //   final db = await database;
  //   List<Map> results = await db.rawQuery("SELECT * FROM User LIMIT 1");
  //   UserModel user = UserModel.fromMap(results[0]);
  //   return user;
  // }

  // Future<UserModel> getClient(String msisdn) async {
  //   final db = await database;
  //   var res = await db.query("User", where: "msisdn = ?", whereArgs: [msisdn]);
  //   return res.isNotEmpty ? UserModel.fromMap(res.first) : null;
  // }

  // fetchClient() async {
  //   final db = await database;
  //   var res = await db.query("User", where: "1 = 1", limit: 1);
  //   return res.isNotEmpty ? UserModel.fromMap(res.first) : null;
  // }
}
