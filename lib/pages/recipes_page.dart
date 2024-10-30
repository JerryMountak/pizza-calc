import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pizza_calc/utils/recipes/recipe.dart';

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
    if (kIsWeb) {
      log("Detected web environment");

      dbPath = join(await getDatabasesPath(), 'fermentation.db');

      // Check if the database exists
      log("Checking if recipes database exists at path: $dbPath");
      dbExists = await databaseExists(dbPath);
    }
    else {
      log("No web environment detected");

      final appDocDir = await getApplicationDocumentsDirectory();
      dbPath = join(appDocDir.path, 'fermentation.db');

      // Check if the database exists
      log("Checking if recipes database exists at path: $dbPath");
      dbExists = await databaseExists(dbPath);
    }
    
    if (!dbExists) {
      // If working on web
      if (kIsWeb) {
        try {
          log("Copying database for web from assets");

          final data = await rootBundle.load('assets/fermentation.db');
          final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
          await databaseFactory.writeDatabaseBytes(dbPath, bytes);

          log("Database copied successfully for web");
        } catch (e) {
          log("Error copying database: $e");
        }
      } 
      else { // Working on Android        
        try {
          log("Creating new copy from assets");

          ByteData data = await rootBundle.load('assets/fermentation.db');
          List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

          // Write the copied database to the device's storage
          await File(dbPath).writeAsBytes(bytes, flush: true);
          log("Database copied successfully from assets to: $dbPath");
        } catch (e) {
          log("Error copying database: $e");
        }
      }
    } else {
      log("Opening existing database at: $dbPath");
    }

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    log("Creating recipes table");
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
        pizzaType INTEGER NOT NULL,
        notes TEXT
      )
    ''');
    log("Recipes table created successfully");
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

// Recipe list widget
class RecipesTab extends StatefulWidget {
  const RecipesTab({super.key});

  @override
  RecipesTabState createState() => RecipesTabState();
}

class RecipesTabState extends State<RecipesTab> {
  late Future<List<PizzaDoughRecipe>> _recipesFuture;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  void _loadRecipes() {
    _recipesFuture = RecipeDatabaseHelper.instance.getAllRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Recipes"),
      ),
      body: FutureBuilder<List<PizzaDoughRecipe>>(
        future: _recipesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No recipes saved'));
          }

          final recipes = snapshot.data!;
          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(recipe.name, style: const TextStyle(fontWeight: FontWeight.bold),),
                  subtitle: Text(
                    'Balls: ${recipe.doughBalls}x${recipe.ballWeight}g, '
                    'Hydration: ${recipe.hydration}%\n'
                    'RT: ${recipe.roomTempHours}h at ${recipe.roomTemp}°C'
                    '${recipe.isMultiStage ? 
                      ', CT: ${recipe.controlledTempHours}h at ${recipe.controlledTemp}°C' 
                      : ''}'
                  ),
                  leading: const Icon(Icons.local_pizza_rounded),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await RecipeDatabaseHelper.instance.deleteRecipe(recipe.id!);
                      setState(() {
                        _loadRecipes();
                      });
                    },
                  ),
                  onTap: () {
                    // Set the selected recipe ID in the provider
                    // context.read<RecipeState>().selectRecipe(recipe.id!);

                    Provider.of<RecipeProvider>(context, listen: false).updateRecipe(recipe);

                    // Switch to the desired home tab after navigating back
                    // context.read<TabController>().index = 0; // Assuming 0 is the index for the home tab
                  }
                ),
              );
            },
          );
        },
      )
    );
      }
}
