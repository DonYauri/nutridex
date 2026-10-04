import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_sqlcipher/sqflite.dart';

import '../models/meal.dart';

/// SQLCipher-backed storage (AES-256). The passphrase is a random 256-bit
/// key generated on first launch and kept in the platform keystore/keychain.
class DbService {
  static const _keyName = 'nutridex_db_key';
  static const _storage = FlutterSecureStorage();
  Database? _db;

  Future<String> _passphrase() async {
    var key = await _storage.read(key: _keyName);
    if (key == null) {
      final rnd = Random.secure();
      key = base64UrlEncode(List<int>.generate(32, (_) => rnd.nextInt(256)));
      await _storage.write(key: _keyName, value: key);
    }
    return key;
  }

  Future<Database> get _database async => _db ??= await _open();

  Future<Database> _open() async {
    final path = p.join(await getDatabasesPath(), 'nutridex.db');
    return openDatabase(
      path,
      password: await _passphrase(),
      version: 1,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE meals(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          calories INTEGER NOT NULL,
          protein REAL NOT NULL,
          carbs REAL NOT NULL,
          fat REAL NOT NULL,
          image_hash TEXT NOT NULL UNIQUE,
          logged_at TEXT NOT NULL
        )'''),
    );
  }

  Future<int> insertMeal(Meal meal) async =>
      (await _database).insert('meals', meal.toMap()..remove('id'));

  Future<List<Meal>> allMeals() async {
    final rows = await (await _database).query('meals', orderBy: 'logged_at DESC');
    return rows.map(Meal.fromMap).toList();
  }

  Future<Meal?> findByHash(String hash) async {
    final rows = await (await _database)
        .query('meals', where: 'image_hash = ?', whereArgs: [hash], limit: 1);
    return rows.isEmpty ? null : Meal.fromMap(rows.first);
  }

  Future<void> deleteMeal(int id) async =>
      (await _database).delete('meals', where: 'id = ?', whereArgs: [id]);
}
