import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'models/profile.dart';

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
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "profile_database.db");
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE profile(
        id INTEGER PRIMARY KEY,
        gender TEXT,
        training_experience TEXT,
        weight REAL
      )
    ''');
  }

  Future<int> insertProfile(Profile profile) async {
    Database db = await database;
    return await db.insert('profile', profile.toMap());
  }

  Future<List<Profile>> getProfiles() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('profile');
    return List.generate(maps.length, (i) {
      return Profile.fromMap(maps[i]);
    });
  }

  Future<int> updateProfile(Profile profile) async {
    Database db = await database;
    return await db.update(
      'profile',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  Future<int> deleteProfile(int id) async {
    Database db = await database;
    return await db.delete(
      'profile',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
