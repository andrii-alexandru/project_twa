import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../sample_feature/favorite_breed.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'favorites.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        breedName TEXT NOT NULL
      )
    ''');
  }

  Future<void> insertFavorite(FavoriteBreed favorite) async {
    final db = await database;
    await db.insert(
      'favorites',
      favorite.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteFavorite(String breedName) async {
    final db = await database;
    await db.delete(
      'favorites',
      where: 'breedName = ?',
      whereArgs: [breedName],
    );
  }

  Future<List<FavoriteBreed>> getFavorites() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('favorites');

    return List.generate(maps.length, (i) {
      return FavoriteBreed(
        breedName: maps[i]['breedName'],
      );
    });
  }

  Future<bool> isFavorite(String breedName) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorites',
      where: 'breedName = ?',
      whereArgs: [breedName],
    );
    return maps.isNotEmpty;
  }
}
