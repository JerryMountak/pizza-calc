import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'dart:developer'; // For logging

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _database;
  // ignore: prefer_final_fields
  Map<String, List<Map<String, dynamic>>> _lookupTables = {}; // Cache for lookup tables

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

    final databaseInstance = await openDatabase(dbPath, singleInstance: false);
    log("Database opened successfully");
    return databaseInstance;
  }

  Future<void> loadLookupTable(String yeastType) async {
    if (!_lookupTables.containsKey(yeastType)) {
      List<Map<String, dynamic>> lookupTable = await getLookupTable(yeastType);
      _lookupTables[yeastType] = lookupTable; // Cache the lookup table
    }
  }

  Future<List<Map<String, dynamic>>> getLookupTable(String yeastType) async {
    final db = await database;
    return await db.query(
      'fermentation_data',
      where: 'yeast_type = ?',
      whereArgs: [yeastType],
    );
  }

  List<Map<String, dynamic>> getCachedLookupTable(String yeastType) {
    return _lookupTables[yeastType] ?? [];
  }
}

// Optimized lookup table structure
class ProofingTimeTable {
  final Map<double, Map<double, double>> _lookupMap = {};
  
  // Constructor to initialize from DB data
  ProofingTimeTable(List<Map<String, dynamic>> data) {
    for (var row in data) {
      double temp = row['temperature'];
      double yeast = row['yeast_percentage'];
      double time = row['time'];

      _lookupMap[temp] ??= {};
      _lookupMap[temp]![yeast] = time;
    }
  }

  // Find the closest key in a Map
  double _findClosestKey(Map<double, double> map, double target) {
    var keys = map.keys.toList()..sort();
    if (keys.isEmpty) throw Exception('Map is empty');

    if (target <= keys.first) return keys.first;
    if (target >= keys.last) return keys.last;

    int left = 0;
    int right = keys.length - 1;
    
    while (left < right) {
      if (right - left == 1) {
        return (target - keys[left]).abs() < (target - keys[right]).abs() 
            ? keys[left] 
            : keys[right];
      }
      int mid = (left + right) ~/ 2;
      if (keys[mid] == target) return keys[mid];

      if (keys[mid] < target) {
        left = mid;
      }
      else {
        right = mid;
      }
    }
    
    return keys[left];
  }

  // Optimized lookup function
  double getProofingTime(double yeast, double temp) {
    var yeastToTimeMap = _lookupMap[temp];
    if (yeastToTimeMap == null || yeastToTimeMap.isEmpty) {
      throw Exception('No data available for temperature $temp°C');
    }

    var exactMatch = yeastToTimeMap[yeast];
    if (exactMatch != null) {
      return exactMatch;
    }

    double closestYeast = _findClosestKey(yeastToTimeMap, yeast);
    return yeastToTimeMap[closestYeast]!;
  }
}

Future<double> calculateFermentationPercentage(
    List<Map<String, dynamic>> lookupTable,
    double temp,
    double hours,
    double yeast) async {
  final proofingTable = ProofingTimeTable(lookupTable);
  double totalTime = proofingTable.getProofingTime(yeast, temp);
  return (hours / totalTime) * 100;
}

Future<double> adjustYeast(
  List<List<double>> fermentationSteps,
  List<Map<String, dynamic>> lookupTable, // Preloaded lookup table
  {
    double initialYeast = 0.3,
    double tolerance = 0.5,
  }
) async {
  double yeast = initialYeast;
  double bestYeast = initialYeast; // To track the best yeast value found
  double bestPercentage = double.infinity; // To track the best total percentage found
  final Set<double> previousResults = {}; // To store previous total percentage
  int iteration = 0; // To count iterations for debugging

  while (iteration < 20) {
    double totalPercentage = 0.0;

    for (var step in fermentationSteps) {
      double hours = step[0];
      double temp = step[1];

      double percentage = await calculateFermentationPercentage(lookupTable, temp, hours, yeast);
      totalPercentage += percentage;

      // Debug information for each step
      log("Step: $step, Yeast: $yeast, Percentage: $percentage");
    }

    // Debug information for the total percentage
    log("Iteration: $iteration, Total Percentage: $totalPercentage");

    // Check if this is the best percentage found so far
    if ((totalPercentage - 100).abs() < bestPercentage) {
      bestPercentage = totalPercentage;
      bestYeast = yeast;
    }

    if ((totalPercentage - 100).abs() < tolerance) {
      log("Desired percentage achieved within tolerance: $totalPercentage");
      return yeast; // Break if we are within the tolerance
    }

    // Check for ocsilation in results
    if (previousResults.contains(totalPercentage)) {
      log("Oscillation detected, best total percentage $bestPercentage, returning best yeast value: $bestYeast");
      return bestYeast; // Return the best yeast value found
    }
    else {
      // Store the current total percentage in the previous percentages list
      previousResults.add(totalPercentage);
    }

    // Adjust yeast based on the total percentage
    if (totalPercentage < 100) {
      yeast += 0.02; // Increase yeast
    } else {
      yeast -= 0.02; // Decrease yeast
    }

    iteration++; // Increment the iteration count
  }

  log("Reached maximum iterations. Best yeast value: $bestYeast");
  return bestYeast; // Return the best yeast value after maximum iterations
}



Future<double> yeastCalc(
  List<List<double>> fermentationSteps,
  List<Map<String, dynamic>> lookupTable, // Pass the preloaded lookup table
  {
    double initialYeast = 0.3,
    double tolerance = 0.5,
  }
) async {
  double yeastAmount = await adjustYeast(
    fermentationSteps,
    lookupTable,
    initialYeast: initialYeast,
    tolerance: tolerance,
  );
  return yeastAmount;
}

