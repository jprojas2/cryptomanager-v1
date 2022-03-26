import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _dbName = 'cryptoManagerDb.db';

  static Map<int, List<String>> migrationScripts = {
    1: [
      '''
            CREATE TABLE accounts(_id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            enc_api_key TEXT,
            enc_secret_key TEXT,
            type INTEGER NOT NULL )
            ''',
      '''
            CREATE TABLE watchlist_items(_id INTEGER PRIMARY KEY,
            coin TEXT NOT NULL )
            ''',
      '''
            CREATE TABLE templates(_id INTEGER PRIMARY KEY,
            name TEXT NOT NULL )
            ''',
      '''
            CREATE TABLE template_items(_id INTEGER PRIMARY KEY,
            coin TEXT NOT NULL,
            weight FLOAT,
            template_id INTEGER,
            FOREIGN KEY(template_id) REFERENCES templates(_id)
            )
            ''',
      '''
            CREATE TABLE snapshot_items(_id INTEGER PRIMARY KEY,
            coin TEXT NOT NULL,
            quantity FLOAT,
            account_id INTEGER,
            FOREIGN KEY(account_id) REFERENCES accounts(_id)
            )
            '''
    ],
    2: [
      '''
            CREATE TABLE user_configuration(_id INTEGER PRIMARY KEY,
            calculate_profitability INTEGER NOT NULL DEFAULT 1
            CHECK (calculate_profitability IN (0, 1)))
            '''
    ],
    3: [
      '''
            ALTER TABLE accounts
            ADD enc_passphrase TEXT;
            '''
    ]
  };

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initiateDatabase();
    return _database;
  }

  _initiateDatabase() async {
    int nbrMigrationScripts = migrationScripts.length;
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, _dbName);
    var db = await openDatabase(
      path,
      version: nbrMigrationScripts,
      onCreate: (Database db, int version) async {
        for (int i = 1; i <= nbrMigrationScripts; i++) {
          for (int e = 0; e < migrationScripts[i]!.length; e++) {
            await db.execute(migrationScripts[i]![e]);
          }
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        for (int i = oldVersion + 1; i <= newVersion; i++) {
          for (int e = 0; e < migrationScripts[i]!.length; e++) {
            await db.execute(migrationScripts[i]![e]);
          }
        }
      },
    );
    return db;
  }

  Future? _onCreate(Database db, int version) {
    db.execute('''
            CREATE TABLE accounts(_id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            enc_api_key TEXT,
            enc_secret_key TEXT,
            type INTEGER NOT NULL )
            ''');
    db.execute('''
            CREATE TABLE watchlist_items(_id INTEGER PRIMARY KEY,
            coin TEXT NOT NULL )
            ''');
    db.execute('''
            CREATE TABLE templates(_id INTEGER PRIMARY KEY,
            name TEXT NOT NULL )
            ''');
    db.execute('''
            CREATE TABLE template_items(_id INTEGER PRIMARY KEY,
            coin TEXT NOT NULL,
            weight FLOAT,
            template_id INTEGER,
            FOREIGN KEY(template_id) REFERENCES templates(_id)
            )
            ''');
    db.execute('''
            CREATE TABLE snapshot_items(_id INTEGER PRIMARY KEY,
            coin TEXT NOT NULL,
            quantity FLOAT,
            account_id INTEGER,
            FOREIGN KEY(account_id) REFERENCES accounts(_id)
            )
            ''');
  }

  Future<int> insert(_tableName, Map<String, dynamic> row) async {
    Database? db = await instance.database;
    return await db!.insert(_tableName, row);
  }

  Future<List<Map<String, dynamic>>> queryAll(_tableName) async {
    Database? db = await instance.database;
    return await db!.query(_tableName);
  }

  Future<Map<String, dynamic?>?>? query(_tableName, id) async {
    Database? db = await instance.database;
    var result = await db!.query(_tableName, where: '_id = ?', whereArgs: [id]);
    if (result.length > 0)
      return result[0];
    else
      return null;
  }

  Future<List<Map<String, dynamic?>?>>? queryWhere(
      _tableName, Map<String, dynamic> whereArgs) async {
    Database? db = await instance.database;

    Map<String, dynamic> whereStatement = _buildWhereStatement(whereArgs);
    return await db!.query(_tableName,
        where: whereStatement["where"], whereArgs: whereStatement["whereArgs"]);
  }

  Future update(_tableName, Map<String, dynamic> row) async {
    Database? db = await instance.database;
    int id = row["_id"];
    return await db!.update(_tableName, row, where: '_id = ?', whereArgs: [id]);
  }

  Future<int> delete(_tableName, int id) async {
    Database? db = await instance.database;
    return await db!.delete(_tableName, where: '_id = ?', whereArgs: [id]);
  }

  Future deleteWhere(_tableName, Map<String, dynamic> whereArgs) async {
    Database? db = await instance.database;
    Map<String, dynamic> whereStatement = _buildWhereStatement(whereArgs);
    return await db!.delete(_tableName,
        where: whereStatement["where"], whereArgs: whereStatement["whereArgs"]);
  }

  Future deleteAll(_tableName) async {
    Database? db = await instance.database;
    return await db!.delete(_tableName);
  }

  Map<String, dynamic> _buildWhereStatement(Map<String, dynamic> whereArgs) {
    List<String> whereStatement = [];
    List<dynamic> whereValues = [];
    whereArgs.forEach((key, value) {
      if (value is List) {
        var _aux = List.generate(5, (index) => "?");
        whereStatement.add("${key.toString()} IN (${_aux.join(",")})");
        whereValues += value;
      } else {
        whereStatement.add("${key.toString()} = ?");
        whereValues.add(value);
      }
    });
    return {"where": whereStatement.join(", "), "whereArgs": whereValues};
  }
}
