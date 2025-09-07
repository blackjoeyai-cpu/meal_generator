// MealPlan model representing a collection of meals for a specific date
// Manages meal plans for calendar-based meal planning

import 'meal.dart';

class MealPlan {
  final String id;
  final DateTime date;
  final Map<MealType, Meal?> meals;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;
  final bool isCompleted;

  const MealPlan({
    required this.id,
    required this.date,
    required this.meals,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.isCompleted = false,
  });

  // Factory constructor for creating MealPlan from JSON/Map
  factory MealPlan.fromJson(Map<String, dynamic> json) {
    final mealsMap = <MealType, Meal?>{};

    for (final mealType in MealType.values) {
      final mealTypeKey = mealType.toString().split('.').last;
      final mealJson = json['${mealTypeKey}_meal'];
      if (mealJson != null) {
        mealsMap[mealType] = Meal.fromJson(mealJson as Map<String, dynamic>);
      } else {
        mealsMap[mealType] = null;
      }
    }

    return MealPlan(
      id: json['id'] as String,
      date: DateTime.parse(json['plan_date'] as String),
      meals: mealsMap,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      notes: json['notes'] as String?,
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }

  // Convert MealPlan to JSON/Map for storage
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'id': id,
      'plan_date': date.toIso8601String().split('T')[0], // Date only
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'notes': notes,
      'is_completed': isCompleted,
    };

    // Add individual meal entries
    for (final entry in meals.entries) {
      final mealTypeKey = entry.key.toString().split('.').last;
      json['${mealTypeKey}_meal'] = entry.value?.toJson();
    }

    return json;
  }

  // Create a copy of MealPlan with modified fields
  MealPlan copyWith({
    String? id,
    DateTime? date,
    Map<MealType, Meal?>? meals,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    bool? isCompleted,
  }) {
    return MealPlan(
      id: id ?? this.id,
      date: date ?? this.date,
      meals: meals ?? Map.from(this.meals),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Add or update a meal for a specific meal type
  MealPlan withMeal(MealType mealType, Meal? meal) {
    final updatedMeals = Map<MealType, Meal?>.from(meals);
    updatedMeals[mealType] = meal;

    return copyWith(meals: updatedMeals, updatedAt: DateTime.now());
  }

  // Remove a meal for a specific meal type
  MealPlan withoutMeal(MealType mealType) {
    return withMeal(mealType, null);
  }

  // Get the meal for a specific meal type
  Meal? getMeal(MealType mealType) {
    return meals[mealType];
  }

  // Check if the meal plan has any meals
  bool get hasAnyMeals {
    return meals.values.any((meal) => meal != null);
  }

  // Get all non-null meals
  List<Meal> get allMeals {
    return meals.values.where((meal) => meal != null).cast<Meal>().toList();
  }

  // Get total preparation time for all meals
  int get totalPreparationTime {
    return allMeals.fold(0, (total, meal) => total + meal.preparationTime);
  }

  // Get total calories for all meals (if available)
  int? get totalCalories {
    final calories = allMeals
        .where((meal) => meal.calories != null)
        .map((meal) => meal.calories!)
        .toList();

    if (calories.isEmpty) return null;
    return calories.fold<int>(0, (total, cal) => total + cal);
  }

  // Check if meal plan is for today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Check if meal plan is in the past
  bool get isPast {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final planDate = DateTime(date.year, date.month, date.day);
    return planDate.isBefore(today);
  }

  // Check if meal plan is in the future
  bool get isFuture {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final planDate = DateTime(date.year, date.month, date.day);
    return planDate.isAfter(today);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MealPlan && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MealPlan(id: $id, date: $date, meals: ${allMeals.length})';
  }
}

// Factory class for creating empty meal plans
class MealPlanFactory {
  static MealPlan createEmpty(DateTime date) {
    return MealPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: date,
      meals: {for (final mealType in MealType.values) mealType: null},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static MealPlan createWithMeals(DateTime date, Map<MealType, Meal> meals) {
    final mealPlan = createEmpty(date);
    final updatedMeals = Map<MealType, Meal?>.from(mealPlan.meals);

    for (final entry in meals.entries) {
      updatedMeals[entry.key] = entry.value;
    }

    return mealPlan.copyWith(meals: updatedMeals);
  }
}
