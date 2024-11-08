import 'dart:io';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:pizza_calc/models/pizza_recipe.dart';

// Database helper class
class RecipeDatabaseHelper {
  static final RecipeDatabaseHelper instance = RecipeDatabaseHelper._init();
  static Database? _database;

  RecipeDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    bool dbExists;
    String dbPath;

    // If working on web
    if (kIsWeb || Platform.isWindows) {
      dev.log("Detected web/windows environment");

      dbPath = join(await getDatabasesPath(), 'fermentation.db');

      // Check if the database exists
      dev.log("Checking if recipes database exists at path: $dbPath");
      dbExists = await databaseExists(dbPath);
    }
    else {
      dev.log("Running on Android");

      final appDocDir = await getApplicationDocumentsDirectory();
      dbPath = join(appDocDir.path, 'fermentation.db');

      // Check if the database exists
      dev.log("Checking if recipes database exists at path: $dbPath");
      dbExists = await databaseExists(dbPath);
    }
    
    if (!dbExists) {
      // If working on web or windows
      if (kIsWeb || Platform.isWindows) {
        try {
          dev.log("Copying database for web from assets");

          final data = await rootBundle.load('assets/fermentation.db');
          final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
          await databaseFactory.writeDatabaseBytes(dbPath, bytes);

          dev.log("Database copied successfully for web");
        } catch (e) {
          dev.log("Error copying database: $e");
        }
      } 
      else { // Working on Android        
        try {
          dev.log("Creating new copy from assets");

          ByteData data = await rootBundle.load('assets/fermentation.db');
          List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

          // Write the copied database to the device's storage
          await File(dbPath).writeAsBytes(bytes, flush: true);
          dev.log("Database copied successfully from assets to: $dbPath");
        } catch (e) {
          dev.log("Error copying database: $e");
        }
      }
    } else {
      dev.log("Opening existing database at: $dbPath");
    }

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    dev.log("Creating recipes table");
    await db.execute('''
      CREATE TABLE IF NOT EXISTS recipes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        doughBalls INTEGER NOT NULL,
        ballWeight INTEGER NOT NULL,
        hydration INTEGER NOT NULL,
        saltPercentage REAL NOT NULL,
        yeastPercentage REAL NOT NULL,
        sugarPercentage REAL,
        fatPercentage REAL,
        roomTemp REAL NOT NULL,
        roomTempHours INTEGER NOT NULL,
        controlledTemp REAL,
        controlledTempHours INTEGER,
        isMultiStage INTEGER NOT NULL,
        hasSugar INTEGER NOT NULL,
        hasFat INTEGER NOT NULL,
        yeastType INTEGER NOT NULL,
        hasPreferment INTEGER NOT NULL,
        prefermentType INTEGER NOT NULL,
        prefermentPercentage INTEGER NOT NULL,
        prefermentHours INTEGER NOT NULL,
        hasTangzhong INTEGER NOT NULL,
        pizzaType INTEGER NOT NULL,
        notes TEXT
      )
    ''');
    dev.log("Recipes table created successfully");
  }

  // CRUD operations
  Future<int> insertRecipe(PizzaDoughRecipe recipe) async {
    final db = await instance.database;
    return await db.insert('recipes', recipe.toMap());
  }

  Future<List<PizzaDoughRecipe>> getAllRecipes() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('recipes');
    return List.generate(maps.length, (i) => PizzaDoughRecipe.fromMap(maps[i]));
  }

  Future<PizzaDoughRecipe?> getRecipeById(int id) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('recipes', where: 'id = ?', whereArgs: [id]);
    return maps.isNotEmpty ? PizzaDoughRecipe.fromMap(maps.first) : null;
  }

  Future<int> updateRecipe(PizzaDoughRecipe recipe) async {
    final db = await instance.database;
    return await db.update(
      'recipes',
      recipe.toMap(),
      where: 'id = ?',
      whereArgs: [recipe.id],
    );
  }

  Future<int> deleteRecipe(int id) async {
    final db = await instance.database;
    return await db.delete(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}