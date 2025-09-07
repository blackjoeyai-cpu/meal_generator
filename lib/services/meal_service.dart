// Meal service for managing individual meals
// Handles CRUD operations for meals and their associated materials

import 'dart:convert';
import '../models/models.dart';
import 'database_service.dart';
import 'material_service.dart';

class MealService {
  final DatabaseService _db = DatabaseService.instance;
  final MaterialService _materialService = MaterialService();

  // Get all meals
  Future<List<Meal>> getAllMeals() async {
    try {
      final List<Map<String, dynamic>> maps = await _db.query('meals');
      final List<Meal> meals = [];

      for (final map in maps) {
        final meal = await _mealFromMap(map);
        meals.add(meal);
      }

      return meals;
    } catch (e) {
      throw Exception('Failed to get meals: $e');
    }
  }

  // Get meals by type
  Future<List<Meal>> getMealsByType(MealType mealType) async {
    try {
      final mealTypeStr = mealType.toString().split('.').last;
      final List<Map<String, dynamic>> maps = await _db.query(
        'meals',
        where: 'meal_type = ?',
        whereArgs: [mealTypeStr],
      );

      final List<Meal> meals = [];
      for (final map in maps) {
        final meal = await _mealFromMap(map);
        meals.add(meal);
      }

      return meals;
    } catch (e) {
      throw Exception('Failed to get meals by type: $e');
    }
  }

  // Get meal by ID
  Future<Meal?> getMealById(String id) async {
    try {
      final List<Map<String, dynamic>> maps = await _db.query(
        'meals',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return await _mealFromMap(maps.first);
    } catch (e) {
      throw Exception('Failed to get meal by ID: $e');
    }
  }

  // Search meals by name or description
  Future<List<Meal>> searchMeals(String query) async {
    try {
      final List<Map<String, dynamic>> maps = await _db.query(
        'meals',
        where: 'name LIKE ? OR description LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
      );

      final List<Meal> meals = [];
      for (final map in maps) {
        final meal = await _mealFromMap(map);
        meals.add(meal);
      }

      return meals;
    } catch (e) {
      throw Exception('Failed to search meals: $e');
    }
  }

  // Get meals that can be made with available materials
  Future<List<Meal>> getMealsWithAvailableMaterials() async {
    try {
      final availableMaterials = await _materialService.getAvailableMaterials();
      final availableMaterialIds = availableMaterials.map((m) => m.id).toSet();

      final allMeals = await getAllMeals();

      return allMeals.where((meal) {
        final mealMaterialIds = meal.materials.map((m) => m.id).toSet();
        return mealMaterialIds.difference(availableMaterialIds).isEmpty;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get meals with available materials: $e');
    }
  }

  // Add a new meal
  Future<void> addMeal(Meal meal) async {
    try {
      await _db.transaction((txn) async {
        // Insert meal
        await txn.insert('meals', _mealToMap(meal));

        // Insert meal materials
        for (final material in meal.materials) {
          await txn.insert('meal_materials', {
            'meal_id': meal.id,
            'material_id': material.id,
            'quantity': '', // Can be extended later
          });
        }
      });
    } catch (e) {
      throw Exception('Failed to add meal: $e');
    }
  }

  // Update an existing meal
  Future<void> updateMeal(Meal meal) async {
    try {
      await _db.transaction((txn) async {
        // Update meal
        final rowsAffected = await txn.update(
          'meals',
          _mealToMap(meal),
          where: 'id = ?',
          whereArgs: [meal.id],
        );

        if (rowsAffected == 0) {
          throw Exception('Meal not found');
        }

        // Delete existing meal materials
        await txn.delete(
          'meal_materials',
          where: 'meal_id = ?',
          whereArgs: [meal.id],
        );

        // Insert updated meal materials
        for (final material in meal.materials) {
          await txn.insert('meal_materials', {
            'meal_id': meal.id,
            'material_id': material.id,
            'quantity': '',
          });
        }
      });
    } catch (e) {
      throw Exception('Failed to update meal: $e');
    }
  }

  // Delete a meal
  Future<void> deleteMeal(String mealId) async {
    try {
      await _db.transaction((txn) async {
        // Delete meal materials first (foreign key constraint)
        await txn.delete(
          'meal_materials',
          where: 'meal_id = ?',
          whereArgs: [mealId],
        );

        // Delete meal
        final rowsAffected = await txn.delete(
          'meals',
          where: 'id = ?',
          whereArgs: [mealId],
        );

        if (rowsAffected == 0) {
          throw Exception('Meal not found');
        }
      });
    } catch (e) {
      throw Exception('Failed to delete meal: $e');
    }
  }

  // Get meals count by type
  Future<Map<MealType, int>> getMealsCountByType() async {
    try {
      final List<Map<String, dynamic>> result = await _db.rawQuery('''
        SELECT meal_type, COUNT(*) as count 
        FROM meals 
        GROUP BY meal_type
      ''');

      final Map<MealType, int> counts = {};

      for (final row in result) {
        final mealTypeStr = row['meal_type'] as String;
        final count = row['count'] as int;

        try {
          final mealType = MealType.values.firstWhere(
            (e) => e.toString().split('.').last == mealTypeStr,
          );
          counts[mealType] = count;
        } catch (e) {
          // Skip unknown meal types
        }
      }

      return counts;
    } catch (e) {
      throw Exception('Failed to get meals count by type: $e');
    }
  }

  // Get total meals count
  Future<int> getTotalMealsCount() async {
    try {
      final List<Map<String, dynamic>> result = await _db.rawQuery('''
        SELECT COUNT(*) as count FROM meals
      ''');

      return result.first['count'] as int;
    } catch (e) {
      throw Exception('Failed to get total meals count: $e');
    }
  }

  // Get materials for a specific meal
  Future<List<Material>> getMealMaterials(String mealId) async {
    try {
      final List<Map<String, dynamic>> maps = await _db.rawQuery(
        '''
        SELECT m.* 
        FROM materials m
        INNER JOIN meal_materials mm ON m.id = mm.material_id
        WHERE mm.meal_id = ?
      ''',
        [mealId],
      );

      final materialService = MaterialService();
      return maps.map((map) => materialService.materialFromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to get meal materials: $e');
    }
  }

  // Convert Meal to database map
  Map<String, dynamic> _mealToMap(Meal meal) {
    return {
      'id': meal.id,
      'name': meal.name,
      'description': meal.description,
      'meal_type': meal.mealType.toString().split('.').last,
      'preparation_time': meal.preparationTime,
      'instructions': meal.instructions,
      'created_at': meal.createdAt.toIso8601String(),
      'image_url': meal.imageUrl,
      'calories': meal.calories,
      'tags': jsonEncode(meal.tags),
    };
  }

  // Convert database map to Meal
  Future<Meal> _mealFromMap(Map<String, dynamic> map) async {
    final materials = await getMealMaterials(map['id'] as String);

    return Meal(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      materials: materials,
      mealType: MealType.values.firstWhere(
        (e) => e.toString().split('.').last == map['meal_type'],
      ),
      preparationTime: map['preparation_time'] as int? ?? 0,
      instructions: map['instructions'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
      imageUrl: map['image_url'] as String?,
      calories: map['calories'] as int?,
      tags: map['tags'] != null
          ? List<String>.from(jsonDecode(map['tags'] as String))
          : [],
    );
  }
}
