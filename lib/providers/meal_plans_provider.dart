// Meal plans provider for managing meal plan state and calendar operations
// Handles meal plan creation, editing, and calendar-based viewing

import 'package:flutter/foundation.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/models.dart';
import '../services/services.dart';

class MealPlansProvider extends ChangeNotifier {
  final MealPlanService _mealPlanService = MealPlanService();
  final MealGeneratorService _mealGeneratorService = MealGeneratorService();

  // State
  final Map<DateTime, MealPlan> _mealPlans = {};
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  bool _isLoading = false;
  bool _isGenerating = false;
  String? _errorMessage;

  // Getters
  Map<DateTime, MealPlan> get mealPlans => _mealPlans;
  MealPlan? get selectedMealPlan => _mealPlans[_normalizeDate(_selectedDate)];
  DateTime get selectedDate => _selectedDate;
  DateTime get focusedDate => _focusedDate;
  CalendarFormat get calendarFormat => _calendarFormat;
  bool get isLoading => _isLoading;
  bool get isGenerating => _isGenerating;
  String? get errorMessage => _errorMessage;

  // Check if date has meal plan
  bool hasMealPlan(DateTime date) {
    return _mealPlans.containsKey(_normalizeDate(date));
  }

  // Get meal plan for specific date
  MealPlan? getMealPlan(DateTime date) {
    return _mealPlans[_normalizeDate(date)];
  }

  // Load meal plans for date range
  Future<void> loadMealPlansForRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      final plans = await _mealPlanService.getMealPlansForDateRange(
        startDate,
        endDate,
      );

      // Update meal plans map
      for (final plan in plans) {
        _mealPlans[_normalizeDate(plan.date)] = plan;
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to load meal plans: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load meal plans for current month
  Future<void> loadCurrentMonthMealPlans() async {
    final firstDay = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final lastDay = DateTime(_focusedDate.year, _focusedDate.month + 1, 0);
    await loadMealPlansForRange(firstDay, lastDay);
  }

  // Generate meal plan for selected date
  Future<void> generateMealPlan(
    List<Material> materials, {
    List<MealType>? includedMealTypes,
    List<String>? dietaryRestrictions,
  }) async {
    _setGenerating(true);
    _clearError();

    try {
      final mealTypes = includedMealTypes ?? MealType.values;
      final dailyMeals = <MealType, Meal?>{};

      for (final mealType in mealTypes) {
        final meals = await _mealGeneratorService.generateMeals(
          availableMaterials: materials,
          mealType: mealType,
          count: 1,
          dietaryRestrictions: dietaryRestrictions,
        );

        if (meals.isNotEmpty) {
          dailyMeals[mealType] = meals.first;
        }
      }

      if (dailyMeals.isNotEmpty) {
        final mealPlan = MealPlan(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          date: _selectedDate,
          meals: {
            for (final mealType in MealType.values)
              mealType: dailyMeals[mealType],
          },
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _mealPlanService.saveMealPlan(mealPlan);
        _mealPlans[_normalizeDate(_selectedDate)] = mealPlan;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to generate meal plan: $e');
    } finally {
      _setGenerating(false);
    }
  }

  // Generate weekly meal plans
  Future<void> generateWeeklyMealPlans(
    DateTime startDate,
    List<Material> materials, {
    List<MealType>? includedMealTypes,
    List<String>? dietaryRestrictions,
  }) async {
    _setGenerating(true);
    _clearError();

    try {
      final weeklyPlans = await _mealGeneratorService.generateWeeklyPlan(
        startDate: startDate,
        materials: materials,
        includedMealTypes: includedMealTypes,
        dietaryRestrictions: dietaryRestrictions,
      );

      for (final entry in weeklyPlans.entries) {
        await _mealPlanService.saveMealPlan(entry.value);
        _mealPlans[_normalizeDate(entry.key)] = entry.value;
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to generate weekly meal plans: $e');
    } finally {
      _setGenerating(false);
    }
  }

  // Save meal plan
  Future<void> saveMealPlan(MealPlan mealPlan) async {
    _setLoading(true);
    _clearError();

    try {
      await _mealPlanService.saveMealPlan(mealPlan);
      _mealPlans[_normalizeDate(mealPlan.date)] = mealPlan;
      notifyListeners();
    } catch (e) {
      _setError('Failed to save meal plan: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update meal plan
  Future<void> updateMealPlan(MealPlan mealPlan) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedPlan = mealPlan.copyWith(updatedAt: DateTime.now());
      await _mealPlanService.updateMealPlan(updatedPlan);
      _mealPlans[_normalizeDate(updatedPlan.date)] = updatedPlan;
      notifyListeners();
    } catch (e) {
      _setError('Failed to update meal plan: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Delete meal plan
  Future<void> deleteMealPlan(String mealPlanId) async {
    _setLoading(true);
    _clearError();

    try {
      await _mealPlanService.deleteMealPlan(mealPlanId);

      // Remove from local state
      _mealPlans.removeWhere((date, plan) => plan.id == mealPlanId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete meal plan: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update specific meal in plan
  Future<void> updateMealInPlan(MealType mealType, Meal? meal) async {
    final currentPlan = selectedMealPlan;
    if (currentPlan != null) {
      final updatedPlan = currentPlan.withMeal(mealType, meal);
      await updateMealPlan(updatedPlan);
    } else {
      // Create new meal plan
      final newPlan = MealPlan(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: _selectedDate,
        meals: {
          for (final type in MealType.values)
            type: type == mealType ? meal : null,
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await saveMealPlan(newPlan);
    }
  }

  // Create a new meal plan with a specific meal
  Future<void> createMealPlanWithMeal(DateTime date, Meal meal) async {
    final newPlan = MealPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: date,
      meals: {
        for (final type in MealType.values)
          type: type == meal.mealType ? meal : null,
      },
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await saveMealPlan(newPlan);
  }

  // Set selected date
  void setSelectedDate(DateTime date) {
    if (_selectedDate != date) {
      _selectedDate = date;
      notifyListeners();
    }
  }

  // Set focused date
  void setFocusedDate(DateTime date) {
    if (_focusedDate != date) {
      _focusedDate = date;
      notifyListeners();
    }
  }

  // Set calendar format
  void setCalendarFormat(CalendarFormat format) {
    if (_calendarFormat != format) {
      _calendarFormat = format;
      notifyListeners();
    }
  }

  // Get events for calendar (meal plans)
  List<MealPlan> getEventsForDay(DateTime day) {
    final plan = _mealPlans[_normalizeDate(day)];
    return plan != null ? [plan] : [];
  }

  // Get meal plan statistics
  Future<Map<String, dynamic>> getMealPlanStatistics() async {
    try {
      return await _mealPlanService.getMealPlanStatistics();
    } catch (e) {
      _setError('Failed to get statistics: $e');
      return {};
    }
  }

  // Normalize date to remove time component
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Set loading state
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  // Set generating state
  void _setGenerating(bool generating) {
    if (_isGenerating != generating) {
      _isGenerating = generating;
      notifyListeners();
    }
  }

  // Set error message
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Clear error message
  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  // Clear error manually
  void clearError() {
    _clearError();
  }
}
