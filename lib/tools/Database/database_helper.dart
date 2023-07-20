import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:wordblitz/tools/Database/game_stats_model.dart';

const String gameStatsTable = "csw22_gamestats";
const String boardGameStatsTable = "csw22_board_gamestats";

class DatabaseHelper{
  static const String _DATABASE_NAME = "csw22gamestats.db";
  static const int _DATABASE_VERSION = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async{
    if(_database!=null){
      List<String> existingTables = await _getExistingTables(_database!);
      if (existingTables.contains(gameStatsTable) &&
          existingTables.contains(boardGameStatsTable)) {
        return _database!;
      }
    }
    _database = await _initiateDatabase();
    return _database!;
  }

  Future<List<String>> _getExistingTables(Database db) async {
    var tablesMap = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'");
    List<String> tables = tablesMap.map((row) => row["name"] as String).toList();
    return tables;
  }

  _initiateDatabase() async{
    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = join(directory.path,_DATABASE_NAME);
    return await openDatabase(path,version: _DATABASE_VERSION, onCreate: _onCreate);
  }

  Future _onCreate(Database db,int version) async{
    final idType = "TEXT PRIMARY KEY";

    final intType = "INTEGER NOT NULL";

    await db.execute('''
    CREATE TABLE $gameStatsTable(
    ${GameStatsFields.word} $idType,
    ${GameStatsFields.embeddedInt} $intType
    )
    ''');

    await db.execute('''
    CREATE TABLE $boardGameStatsTable(
    ${BoardGameStatsFields.word} $idType,
    ${BoardGameStatsFields.embeddedInt} $intType
    )
    ''');
  }

  Future deleteTable({String accessedTable = gameStatsTable}) async{
    final db = await instance.database;
    await db.execute("DROP TABLE IF EXISTS $accessedTable");
  }

  Future<GameStats> create(GameStats gameStats,{String accessedTable = gameStatsTable}) async{
    final db = await instance.database;

    /*final id = */await db.insert(accessedTable, gameStats.toJson());

    return gameStats;
  }
  Future<void> bulkCreate(List<GameStats> gameStatsList,{String accessedTable = gameStatsTable}) async {
    final db = await instance.database;

    Batch batch = db.batch();

    for (GameStats gameStats in gameStatsList) {
      batch.insert(accessedTable, gameStats.toJson());
    }

    await batch.commit(noResult: true);
  }

  Future<GameStats> readGameStats(String word,{String accessedTable = gameStatsTable}) async{
    final db = await instance.database;

    final maps = await db.query(
      accessedTable,
      columns: GameStatsFields.values,
      where: '${GameStatsFields.word} = ?',
      whereArgs: [word],
    );

    if (maps.isNotEmpty) {
      return GameStats.fromJson(maps.first);
    } else {
      throw WordNotFoundException("word $word not in database");
    }
  }

  Future<List<GameStats>> readAllGameStats({String accessedTable = gameStatsTable}) async {
    final db = await instance.database;

    final result = await db.query(accessedTable);

    return await result.map((json) => GameStats.fromJson(json)).toList();
  }

  Future<int> update(GameStats gameStats,{String accessedTable = gameStatsTable}) async{
    final db = await instance.database;

    return db.update(
      accessedTable,
      gameStats.toJson(),
      where: "${GameStatsFields.word} = ?",
      whereArgs: [gameStats.word],
    );
  }

  Future<int> delete(String word,{String accessedTable = gameStatsTable}) async{
    final db = await instance.database;

    return await db.delete(
      accessedTable,
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

class WordNotFoundException implements Exception{
  final String message;
  WordNotFoundException(this.message);
}