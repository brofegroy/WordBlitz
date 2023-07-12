import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:wordblitz/tools/Database/game_stats_model.dart';

class DatabaseHelper{
  static const String _DATABASE_NAME = "csw22gamestats.db";
  static const int _DATABASE_VERSION = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async{
    if(_database!=null) return _database!;

    _database = await _initiateDatabase();
    return _database!;
  }

  _initiateDatabase() async{
    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = join(directory.path,_DATABASE_NAME);
    return await openDatabase(path,version: _DATABASE_VERSION, onCreate: _onCreate);
  }

  Future _onCreate(Database db,int version) async{
    final idType = "TEXT PRIMARY KEY";

    final boolType = "BOOLEAN NOT NULL";
    final intType = "INTEGER NOT NULL";

    await db.execute('''
    CREATE TABLE $gameStatsTable(
    ${GameStatsFields.word} $idType,
    ${GameStatsFields.isWordCorrect} $boolType,
    ${GameStatsFields.correctGuesses} $intType,
    ${GameStatsFields.misses} $intType,
    ${GameStatsFields.wrongGuesses} $intType,
    ${GameStatsFields.total} $intType
    )
    ''');
  }

  Future<GameStats> create(GameStats gameStats) async{
    final db = await instance.database;

    final id = await db.insert(gameStatsTable, gameStats.toJson());

    return gameStats;
  }

  Future<GameStats> readGameStats(String word) async{
    final db = await instance.database;

    final maps = await db.query(
      gameStatsTable,
      columns: GameStatsFields.values,
      where: '${GameStatsFields.word} = ?',
      whereArgs: [word],
    );

    if (maps.isNotEmpty) {
      return GameStats.fromJson(maps.first);
    } else {
      throw Exception("word $word not in database");
    }
  }

  Future<List<GameStats>> readAllGameStats() async {
    final db = await instance.database;

    final orderBy = "${GameStatsFields.total} DESC";

    final result = await db.query(gameStatsTable, orderBy: orderBy);

    return await result.map((json) => GameStats.fromJson(json)).toList();
  }

  Future<int> update(GameStats gameStats) async{
    final db = await instance.database;

    return db.update(
      gameStatsTable,
      gameStats.toJson(),
      where: "${GameStatsFields.word} = ?",
      whereArgs: [gameStats.word],
    );
  }

  Future<int> delete(String word) async{
    final db = await instance.database;

    return await db.delete(
      gameStatsTable,
      where: "${GameStatsFields.word} = ?",
      whereArgs: [word],
    );
  }

  Future close() async{
    final db = await instance.database;

    db.close();
    return;
  }
}