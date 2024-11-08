import 'dart:io';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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

    // If working on web or windows
    if (kIsWeb || Platform.isWindows) {
      dev.log("Detected web/windows environment");

      dbPath = join(await getDatabasesPath(), 'fermentation.db');

      // Check if the database exists
      dev.log("Checking if recipes database exists at path: $dbPath");
      dbExists = await databaseExists(dbPath);
    }
    else {
      dev.log("No web environment detected");

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

    final databaseInstance = await openDatabase(dbPath, singleInstance: false);
    dev.log("Database opened successfully");
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