import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static late Database database;

  static Future<void> initDatabase() async {
    if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String dbPath = await _getDatabasePath('items.db');

    database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE items (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, description TEXT, completed INTEGER DEFAULT 0)'
        );
      },
    );
  } 

  static Future<String> _getDatabasePath(String dbName) async {
    if (kIsWeb) {
      return dbName;
    } else {
      Directory documentDirectory = await getApplicationDocumentsDirectory();
      return join(documentDirectory.path, dbName);
    }
  }
}