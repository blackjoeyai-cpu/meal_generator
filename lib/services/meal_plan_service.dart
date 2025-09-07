// Meal plan service for managing daily meal plans
// Handles CRUD operations for meal plans and calendar-based operations

import '../models/models.dart';
import 'database_service.dart';
import 'meal_service.dart';

class MealPlanService {
  final DatabaseService _db = DatabaseService.instance;
  final MealService _mealService = MealService();

  // Get meal plan for a specific date
  Future<MealPlan?> getMealPlanForDate(DateTime date) async {
    try {
      final dateStr = _dateToString(date);
      final List<Map<String, dynamic>> maps = await _db.query(
        'meal_plans',
        where: 'plan_date = ?',
        whereArgs: [dateStr],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return await _mealPlanFromMap(maps.first);
    } catch (e) {
      throw Exception('Failed to get meal plan for date: $e');
    }
  }

  // Get meal plans for a date range
  Future<List<MealPlan>> getMealPlansForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final startDateStr = _dateToString(startDate);
      final endDateStr = _dateToString(endDate);

      final List<Map<String, dynamic>> maps = await _db.query(
        'meal_plans',
        where: 'plan_date >= ? AND plan_date <= ?',
        whereArgs: [startDateStr, endDateStr],
        orderBy: 'plan_date ASC',
      );

      final List<MealPlan> mealPlans = [];
      for (final map in maps) {
        final mealPlan = await _mealPlanFromMap(map);
        mealPlans.add(mealPlan);
      }

      return mealPlans;
    } catch (e) {
      throw Exception('Failed to get meal plans for date range: $e');
    }
  }

  // Get all meal plans
  Future<List<MealPlan>> getAllMealPlans() async {
    try {
      final List<Map<String, dynamic>> maps = await _db.query(
        'meal_plans',
        orderBy: 'plan_date DESC',
      );

      final List<MealPlan> mealPlans = [];
      for (final map in maps) {
        final mealPlan = await _mealPlanFromMap(map);
        mealPlans.add(mealPlan);
      }

      return mealPlans;
    } catch (e) {
      throw Exception('Failed to get all meal plans: $e');
    }
  }

  // Save a new meal plan
  Future<void> saveMealPlan(MealPlan mealPlan) async {
    try {
      await _db.insert('meal_plans', _mealPlanToMap(mealPlan));
    } catch (e) {
      throw Exception('Failed to save meal plan: $e');
    }
  }

  // Update an existing meal plan
  Future<void> updateMealPlan(MealPlan mealPlan) async {
    try {
      final rowsAffected = await _db.update(
        'meal_plans',
        _mealPlanToMap(mealPlan),
        where: 'id = ?',
        whereArgs: [mealPlan.id],
      );

      if (rowsAffected == 0) {
        throw Exception('Meal plan not found');
      }
    } catch (e) {
      throw Exception('Failed to update meal plan: $e');
    }
  }

  // Delete a meal plan
  Future<void> deleteMealPlan(String planId) async {
    try {
      final rowsAffected = await _db.delete(
        'meal_plans',
        where: 'id = ?',
        whereArgs: [planId],
      );

      if (rowsAffected == 0) {
        throw Exception('Meal plan not found');
      }
    } catch (e) {
      throw Exception('Failed to delete meal plan: $e');
    }
  }

  // Check if a meal plan exists for a specific date
  Future<bool> hasMealPlanForDate(DateTime date) async {
    try {
      final mealPlan = await getMealPlanForDate(date);
      return mealPlan != null;
    } catch (e) {
      throw Exception('Failed to check meal plan existence: $e');
    }
  }

  // Get meal plans for current week
  Future<List<MealPlan>> getWeeklyMealPlans([DateTime? startOfWeek]) async {
    try {
      final start = startOfWeek ?? _getStartOfWeek(DateTime.now());
      final end = start.add(const Duration(days: 6));

      return await getMealPlansForDateRange(start, end);
    } catch (e) {
      throw Exception('Failed to get weekly meal plans: $e');
    }
  }

  // Get meal plans for current month
  Future<List<MealPlan>> getMonthlyMealPlans([DateTime? month]) async {
    try {
      final targetMonth = month ?? DateTime.now();
      final start = DateTime(targetMonth.year, targetMonth.month, 1);
      final end = DateTime(targetMonth.year, targetMonth.month + 1, 0);

      return await getMealPlansForDateRange(start, end);
    } catch (e) {
      throw Exception('Failed to get monthly meal plans: $e');
    }
  }

  // Update specific meal in a meal plan
  Future<void> updateMealInPlan(
    String planId,
    MealType mealType,
    Meal? meal,
  ) async {
    try {
      final existingPlan = await _getMealPlanById(planId);
      if (existingPlan == null) {
        throw Exception('Meal plan not found');
      }

      final updatedPlan = existingPlan.withMeal(mealType, meal);
      await updateMealPlan(updatedPlan);
    } catch (e) {
      throw Exception('Failed to update meal in plan: $e');
    }
  }

  // Mark meal plan as completed
  Future<void> markMealPlanCompleted(String planId, bool isCompleted) async {
    try {
      final rowsAffected = await _db.update(
        'meal_plans',
        {
          'is_completed': isCompleted ? 1 : 0,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [planId],
      );

      if (rowsAffected == 0) {
        throw Exception('Meal plan not found');
      }
    } catch (e) {
      throw Exception('Failed to mark meal plan completed: $e');
    }
  }

  // Get meal plan statistics
  Future<Map<String, dynamic>> getMealPlanStatistics() async {
    try {
      final totalPlans = await _db.rawQuery(
        'SELECT COUNT(*) as count FROM meal_plans',
      );
      final completedPlans = await _db.rawQuery(
        'SELECT COUNT(*) as count FROM meal_plans WHERE is_completed = 1',
      );
      final thisWeekPlans = await _db.rawQuery(
        '''
        SELECT COUNT(*) as count FROM meal_plans 
        WHERE plan_date >= ? AND plan_date <= ?
      ''',
        [
          _dateToString(_getStartOfWeek(DateTime.now())),
          _dateToString(
            _getStartOfWeek(DateTime.now()).add(const Duration(days: 6)),
          ),
        ],
      );

      return {
        'total_plans': totalPlans.first['count'],
        'completed_plans': completedPlans.first['count'],
        'this_week_plans': thisWeekPlans.first['count'],
      };
    } catch (e) {
      throw Exception('Failed to get meal plan statistics: $e');
    }
  }

  // Get meal plan by ID
  Future<MealPlan?> _getMealPlanById(String planId) async {
    try {
      final List<Map<String, dynamic>> maps = await _db.query(
        'meal_plans',
        where: 'id = ?',
        whereArgs: [planId],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return await _mealPlanFromMap(maps.first);
    } catch (e) {
      throw Exception('Failed to get meal plan by ID: $e');
    }
  }

  // Convert MealPlan to database map
  Map<String, dynamic> _mealPlanToMap(MealPlan mealPlan) {
    return {
      'id': mealPlan.id,
      'plan_date': _dateToString(mealPlan.date),
      'breakfast_meal_id': mealPlan.getMeal(MealType.breakfast)?.id,
      'lunch_meal_id': mealPlan.getMeal(MealType.lunch)?.id,
      'dinner_meal_id': mealPlan.getMeal(MealType.dinner)?.id,
      'snack_meal_id': mealPlan.getMeal(MealType.snack)?.id,
      'created_at': mealPlan.createdAt.toIso8601String(),
      'updated_at': mealPlan.updatedAt.toIso8601String(),
      'notes': mealPlan.notes,
      'is_completed': mealPlan.isCompleted ? 1 : 0,
    };
  }

  // Convert database map to MealPlan
  Future<MealPlan> _mealPlanFromMap(Map<String, dynamic> map) async {
    final meals = <MealType, Meal?>{};

    // Load meals for each meal type
    for (final mealType in MealType.values) {
      final mealTypeKey = mealType.toString().split('.').last;
      final mealId = map['${mealTypeKey}_meal_id'] as String?;

      if (mealId != null) {
        meals[mealType] = await _mealService.getMealById(mealId);
      } else {
        meals[mealType] = null;
      }
    }

    return MealPlan(
      id: map['id'] as String,
      date: DateTime.parse(map['plan_date'] as String),
      meals: meals,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      notes: map['notes'] as String?,
      isCompleted: (map['is_completed'] as int?) == 1,
    );
  }

  // Helper method to convert DateTime to date string
  String _dateToString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Helper method to get start of week (Monday)
  DateTime _getStartOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return date.subtract(Duration(days: daysFromMonday));
  }
}
