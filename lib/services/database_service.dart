// Platform-aware database service supporting SQLite (Android) and SharedPreferences (Web)
// Provides a unified interface for database operations across platforms

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DatabaseService {
  static DatabaseService? _instance;
  static Database? _database;
  static SharedPreferences? _prefs;

  // In-memory storage for web platform
  static final Map<String, List<Map<String, dynamic>>> _webStorage = {
    'materials': [],
    'meals': [],
    'meal_materials': [],
    'meal_plans': [],
  };

  DatabaseService._internal();

  static DatabaseService get instance {
    _instance ??= DatabaseService._internal();
    return _instance!;
  }

  // Get database instance
  Future<Database?> get database async {
    if (kIsWeb) {
      // Web platform uses SharedPreferences, no SQLite database
      await _initWebStorage();
      return null;
    }

    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize database based on platform
  Future<Database> _initDatabase() async {
    return await _initMobileDatabase();
  }

  // Initialize web storage using SharedPreferences
  Future<void> _initWebStorage() async {
    _prefs ??= await SharedPreferences.getInstance();

    // Load existing data from SharedPreferences
    for (final table in _webStorage.keys) {
      final dataJson = _prefs!.getString('table_$table');
      if (dataJson != null) {
        final List<dynamic> decoded = json.decode(dataJson);
        _webStorage[table] = decoded.cast<Map<String, dynamic>>();
      }
    }
  }

  // Save web storage data to SharedPreferences
  Future<void> _saveWebStorage() async {
    if (_prefs == null) return;

    for (final entry in _webStorage.entries) {
      await _prefs!.setString('table_${entry.key}', json.encode(entry.value));
    }
  }

  // Initialize mobile database using SQLite
  Future<Database> _initMobileDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'meal_planner.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
      onUpgrade: _upgradeDatabase,
    );
  }

  // Create database tables
  Future<void> _createTables(Database db, int version) async {
    // Materials table
    await db.execute('''
      CREATE TABLE materials (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        nutritional_info TEXT,
        is_available INTEGER DEFAULT 1,
        description TEXT,
        image_url TEXT
      )
    ''');

    // Meals table
    await db.execute('''
      CREATE TABLE meals (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        meal_type TEXT NOT NULL,
        preparation_time INTEGER DEFAULT 0,
        instructions TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        image_url TEXT,
        calories INTEGER,
        tags TEXT
      )
    ''');

    // Meal materials junction table
    await db.execute('''
      CREATE TABLE meal_materials (
        meal_id TEXT,
        material_id TEXT,
        quantity TEXT,
        FOREIGN KEY (meal_id) REFERENCES meals (id) ON DELETE CASCADE,
        FOREIGN KEY (material_id) REFERENCES materials (id) ON DELETE CASCADE,
        PRIMARY KEY (meal_id, material_id)
      )
    ''');

    // Meal plans table
    await db.execute('''
      CREATE TABLE meal_plans (
        id TEXT PRIMARY KEY,
        plan_date DATE NOT NULL,
        breakfast_meal_id TEXT,
        lunch_meal_id TEXT,
        dinner_meal_id TEXT,
        snack_meal_id TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        notes TEXT,
        is_completed INTEGER DEFAULT 0,
        FOREIGN KEY (breakfast_meal_id) REFERENCES meals (id) ON DELETE SET NULL,
        FOREIGN KEY (lunch_meal_id) REFERENCES meals (id) ON DELETE SET NULL,
        FOREIGN KEY (dinner_meal_id) REFERENCES meals (id) ON DELETE SET NULL,
        FOREIGN KEY (snack_meal_id) REFERENCES meals (id) ON DELETE SET NULL
      )
    ''');

    // Create indexes for better performance
    await db.execute(
      'CREATE INDEX idx_materials_category ON materials (category)',
    );
    await db.execute(
      'CREATE INDEX idx_materials_available ON materials (is_available)',
    );
    await db.execute('CREATE INDEX idx_meals_type ON meals (meal_type)');
    await db.execute(
      'CREATE INDEX idx_meal_plans_date ON meal_plans (plan_date)',
    );
  }

  // Handle database upgrades
  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Handle future database schema upgrades
    if (oldVersion < newVersion) {
      // Add migration logic here when needed
    }
  }

  // Generic query method
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    if (kIsWeb) {
      await _initWebStorage();
      List<Map<String, dynamic>> results = List.from(_webStorage[table] ?? []);

      // Apply basic where clause filtering for web
      if (where != null && whereArgs != null) {
        results = _applyWhereClause(results, where, whereArgs);
      }

      // Apply ordering
      if (orderBy != null) {
        results = _applyOrderBy(results, orderBy);
      }

      // Apply limit
      if (limit != null) {
        final startIndex = offset ?? 0;
        final endIndex = startIndex + limit;
        if (startIndex < results.length) {
          results = results.sublist(
            startIndex,
            endIndex.clamp(0, results.length),
          );
        } else {
          results = [];
        }
      }

      return results;
    }

    final db = await database;
    return await db!.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  // Generic insert method
  Future<int> insert(String table, Map<String, dynamic> values) async {
    if (kIsWeb) {
      await _initWebStorage();
      _webStorage[table]!.add(Map<String, dynamic>.from(values));
      await _saveWebStorage();
      return _webStorage[table]!.length; // Return a fake ID
    }

    final db = await database;
    return await db!.insert(
      table,
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Generic update method
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    if (kIsWeb) {
      await _initWebStorage();
      int updatedCount = 0;

      if (where != null && whereArgs != null) {
        final items = _webStorage[table]!;
        for (int i = 0; i < items.length; i++) {
          if (_matchesWhereClause(items[i], where, whereArgs)) {
            items[i].addAll(values);
            updatedCount++;
          }
        }
      }

      await _saveWebStorage();
      return updatedCount;
    }

    final db = await database;
    return await db!.update(table, values, where: where, whereArgs: whereArgs);
  }

  // Generic delete method
  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    if (kIsWeb) {
      await _initWebStorage();
      int deletedCount = 0;

      if (where != null && whereArgs != null) {
        final items = _webStorage[table]!;
        items.removeWhere((item) {
          final matches = _matchesWhereClause(item, where, whereArgs);
          if (matches) deletedCount++;
          return matches;
        });
      } else {
        deletedCount = _webStorage[table]!.length;
        _webStorage[table]!.clear();
      }

      await _saveWebStorage();
      return deletedCount;
    }

    final db = await database;
    return await db!.delete(table, where: where, whereArgs: whereArgs);
  }

  // Execute raw SQL
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    if (kIsWeb) {
      // For web, we'll need to parse basic SQL queries
      // This is a simplified implementation
      await _initWebStorage();
      return []; // Return empty for complex queries on web
    }

    final db = await database;
    return await db!.rawQuery(sql, arguments);
  }

  // Execute raw SQL
  Future<int> rawExecute(String sql, [List<dynamic>? arguments]) async {
    if (kIsWeb) {
      // For web, return 0 for raw execute operations
      return 0;
    }

    final db = await database;
    return await db!.rawUpdate(sql, arguments);
  }

  // Transaction support
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    if (kIsWeb) {
      // For web, execute without transaction support
      return await action(WebTransaction(this));
    }

    final db = await database;
    return await db!.transaction(action);
  }

  // Close database
  Future<void> close() async {
    if (kIsWeb) {
      await _saveWebStorage();
      return;
    }

    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // Clear all data (useful for testing)
  Future<void> clearAllData() async {
    if (kIsWeb) {
      for (final key in _webStorage.keys) {
        _webStorage[key]!.clear();
      }
      await _saveWebStorage();
      return;
    }

    final db = await database;
    await db!.transaction((txn) async {
      await txn.delete('meal_plans');
      await txn.delete('meal_materials');
      await txn.delete('meals');
      await txn.delete('materials');
    });
  }

  // Get database info
  Future<Map<String, dynamic>> getDatabaseInfo() async {
    if (kIsWeb) {
      return {
        'platform': 'web',
        'storage': 'SharedPreferences',
        'tables': _webStorage.keys.toList(),
      };
    }

    final db = await database;
    final version = await db!.getVersion();
    final path = db.path;

    return {
      'version': version,
      'path': path,
      'platform': 'mobile',
      'isOpen': db.isOpen,
    };
  }

  // Helper methods for web storage
  List<Map<String, dynamic>> _applyWhereClause(
    List<Map<String, dynamic>> data,
    String where,
    List<dynamic> whereArgs,
  ) {
    return data
        .where((item) => _matchesWhereClause(item, where, whereArgs))
        .toList();
  }

  bool _matchesWhereClause(
    Map<String, dynamic> item,
    String where,
    List<dynamic> whereArgs,
  ) {
    if (where.contains(' = ?') && whereArgs.isNotEmpty) {
      final field = where.split(' = ?')[0].trim();
      return item[field] == whereArgs[0];
    }
    return true;
  }

  List<Map<String, dynamic>> _applyOrderBy(
    List<Map<String, dynamic>> data,
    String orderBy,
  ) {
    final parts = orderBy.split(' ');
    if (parts.isNotEmpty) {
      final field = parts[0];
      final ascending = parts.length < 2 || parts[1].toLowerCase() != 'desc';

      data.sort((a, b) {
        final aVal = a[field];
        final bVal = b[field];

        if (aVal == null && bVal == null) return 0;
        if (aVal == null) return ascending ? -1 : 1;
        if (bVal == null) return ascending ? 1 : -1;

        final comparison = aVal.toString().compareTo(bVal.toString());
        return ascending ? comparison : -comparison;
      });
    }
    return data;
  }
}

// Simple transaction wrapper for web platform
class WebTransaction implements Transaction {
  final DatabaseService _service;

  WebTransaction(this._service);

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) async {
    // Not implemented for web
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    return await _service.rawQuery(sql, arguments);
  }

  @override
  Future<int> rawInsert(String sql, [List<Object?>? arguments]) async {
    return await _service.rawExecute(sql, arguments);
  }

  @override
  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) async {
    return await _service.rawExecute(sql, arguments);
  }

  @override
  Future<int> rawDelete(String sql, [List<Object?>? arguments]) async {
    return await _service.rawExecute(sql, arguments);
  }

  @override
  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    return await _service.insert(table, values);
  }

  @override
  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    return await _service.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    return await _service.update(
      table,
      values,
      where: where,
      whereArgs: whereArgs,
    );
  }

  @override
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    return await _service.delete(table, where: where, whereArgs: whereArgs);
  }

  @override
  Batch batch() {
    throw UnimplementedError('Batch operations not implemented for web');
  }

  @override
  Future<QueryCursor> queryCursor(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
    int? bufferSize,
  }) async {
    throw UnimplementedError('Cursor operations not implemented for web');
  }

  @override
  Future<QueryCursor> rawQueryCursor(
    String sql,
    List<Object?>? arguments, {
    int? bufferSize,
  }) async {
    throw UnimplementedError('Cursor operations not implemented for web');
  }

  @override
  Database get database {
    throw UnimplementedError(
      'Database access not available for web transactions',
    );
  }
}
