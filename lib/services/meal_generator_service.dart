// Meal generator service implementing the core meal generation algorithm
// Generates meals and meal plans based on available materials and preferences

import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/models.dart';

class MealGeneratorService {
  final Random _random = Random();
  final Uuid _uuid = const Uuid();

  // Generate meals based on available materials and meal type
  Future<List<Meal>> generateMeals({
    required List<Material> availableMaterials,
    required MealType mealType,
    int count = 3,
    List<String>? dietaryRestrictions,
  }) async {
    try {
      if (availableMaterials.isEmpty) {
        throw Exception('No materials available for meal generation');
      }

      final List<Meal> generatedMeals = [];
      final usedCombinations = <Set<String>>{};

      for (int i = 0; i < count; i++) {
        final meal = await _generateSingleMeal(
          availableMaterials: availableMaterials,
          mealType: mealType,
          usedCombinations: usedCombinations,
          dietaryRestrictions: dietaryRestrictions,
        );

        if (meal != null) {
          generatedMeals.add(meal);
          usedCombinations.add(meal.materials.map((m) => m.id).toSet());
        }
      }

      return generatedMeals;
    } catch (e) {
      throw Exception('Failed to generate meals: $e');
    }
  }

  // Generate a custom meal with specific required materials
  Future<Meal?> generateCustomMeal({
    required List<Material> requiredMaterials,
    required MealType mealType,
    List<Material>? additionalMaterials,
    List<String>? dietaryRestrictions,
  }) async {
    try {
      if (requiredMaterials.isEmpty) {
        throw Exception('At least one required material must be provided');
      }

      final allMaterials = <Material>[];
      allMaterials.addAll(requiredMaterials);

      if (additionalMaterials != null) {
        allMaterials.addAll(additionalMaterials);
      }

      return await _generateSingleMeal(
        availableMaterials: allMaterials,
        mealType: mealType,
        usedCombinations: {},
        dietaryRestrictions: dietaryRestrictions,
        requiredMaterials: requiredMaterials,
      );
    } catch (e) {
      throw Exception('Failed to generate custom meal: $e');
    }
  }

  // Generate weekly meal plan
  Future<Map<DateTime, MealPlan>> generateWeeklyPlan({
    required DateTime startDate,
    required List<Material> materials,
    List<MealType>? includedMealTypes,
    List<String>? dietaryRestrictions,
  }) async {
    try {
      final mealTypes = includedMealTypes ?? MealType.values;
      final weeklyPlans = <DateTime, MealPlan>{};

      for (int i = 0; i < 7; i++) {
        final date = startDate.add(Duration(days: i));
        final dailyMeals = <MealType, Meal?>{};

        for (final mealType in mealTypes) {
          final meals = await generateMeals(
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
            id: _uuid.v4(),
            date: date,
            meals: {
              for (final mealType in MealType.values)
                mealType: dailyMeals[mealType],
            },
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          weeklyPlans[date] = mealPlan;
        }
      }

      return weeklyPlans;
    } catch (e) {
      throw Exception('Failed to generate weekly plan: $e');
    }
  }

  // Generate monthly meal plan
  Future<Map<DateTime, MealPlan>> generateMonthlyPlan({
    required DateTime month,
    required List<Material> materials,
    List<MealType>? includedMealTypes,
    List<String>? dietaryRestrictions,
  }) async {
    try {
      final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
      final daysInMonth = lastDayOfMonth.day;

      final monthlyPlans = <DateTime, MealPlan>{};

      for (int day = 1; day <= daysInMonth; day++) {
        final date = DateTime(month.year, month.month, day);

        // Skip weekends if desired (can be made configurable)
        if (date.weekday == DateTime.saturday ||
            date.weekday == DateTime.sunday) {
          continue;
        }

        final weekPlans = await generateWeeklyPlan(
          startDate: date,
          materials: materials,
          includedMealTypes: includedMealTypes,
          dietaryRestrictions: dietaryRestrictions,
        );

        if (weekPlans.containsKey(date)) {
          monthlyPlans[date] = weekPlans[date]!;
        }

        // Skip to next week to avoid too much repetition
        day += 6;
      }

      return monthlyPlans;
    } catch (e) {
      throw Exception('Failed to generate monthly plan: $e');
    }
  }

  // Generate a single meal using the meal generation algorithm
  Future<Meal?> _generateSingleMeal({
    required List<Material> availableMaterials,
    required MealType mealType,
    required Set<Set<String>> usedCombinations,
    List<String>? dietaryRestrictions,
    List<Material>? requiredMaterials,
  }) async {
    try {
      // Filter materials based on dietary restrictions
      final filteredMaterials = _filterMaterialsByDietaryRestrictions(
        availableMaterials,
        dietaryRestrictions,
      );

      if (filteredMaterials.isEmpty) {
        return null;
      }

      // Generate material combinations
      final combinations = _generateMaterialCombinations(
        materials: filteredMaterials,
        mealType: mealType,
        usedCombinations: usedCombinations,
        requiredMaterials: requiredMaterials,
      );

      if (combinations.isEmpty) {
        return null;
      }

      // Score and select best combination
      final bestCombination = _selectBestCombination(combinations, mealType);

      if (bestCombination.isEmpty) {
        return null;
      }

      // Generate meal details
      return _createMealFromMaterials(bestCombination, mealType);
    } catch (e) {
      return null;
    }
  }

  // Filter materials based on dietary restrictions
  List<Material> _filterMaterialsByDietaryRestrictions(
    List<Material> materials,
    List<String>? dietaryRestrictions,
  ) {
    if (dietaryRestrictions == null || dietaryRestrictions.isEmpty) {
      return materials;
    }

    return materials.where((material) {
      for (final restriction in dietaryRestrictions) {
        switch (restriction.toLowerCase()) {
          case 'vegetarian':
            if (material.category == MaterialCategory.meat ||
                material.category == MaterialCategory.seafood) {
              return false;
            }
            break;
          case 'vegan':
            if (material.category == MaterialCategory.meat ||
                material.category == MaterialCategory.seafood ||
                material.category == MaterialCategory.dairy) {
              return false;
            }
            break;
          case 'pescatarian':
            if (material.category == MaterialCategory.meat) {
              return false;
            }
            break;
          case 'gluten-free':
            if (material.category == MaterialCategory.grains &&
                material.name.toLowerCase().contains('wheat')) {
              return false;
            }
            break;
        }
      }
      return true;
    }).toList();
  }

  // Generate material combinations based on meal type rules
  List<List<Material>> _generateMaterialCombinations({
    required List<Material> materials,
    required MealType mealType,
    required Set<Set<String>> usedCombinations,
    List<Material>? requiredMaterials,
  }) {
    final combinations = <List<Material>>[];
    final rules = _getMealTypeRules(mealType);

    // Try to generate multiple combinations
    for (int attempt = 0; attempt < 50; attempt++) {
      final combination = <Material>[];

      // Add required materials first
      if (requiredMaterials != null) {
        combination.addAll(requiredMaterials);
      }

      // Add materials based on meal type rules
      final proteinMaterials = materials
          .where(
            (m) =>
                m.category == MaterialCategory.meat ||
                m.category == MaterialCategory.seafood ||
                m.category == MaterialCategory.poultry,
          )
          .toList();

      final vegetableMaterials = materials
          .where((m) => m.category == MaterialCategory.vegetables)
          .toList();

      final grainMaterials = materials
          .where((m) => m.category == MaterialCategory.grains)
          .toList();

      final spiceMaterials = materials
          .where((m) => m.category == MaterialCategory.spices)
          .toList();

      // Add protein (if required and not already added)
      if (rules.requiresProtein &&
          combination.where((m) => proteinMaterials.contains(m)).isEmpty) {
        if (proteinMaterials.isNotEmpty) {
          combination.add(
            proteinMaterials[_random.nextInt(proteinMaterials.length)],
          );
        }
      }

      // Add vegetables
      if (rules.requiresVegetables && vegetableMaterials.isNotEmpty) {
        final vegCount = _random.nextInt(2) + 1; // 1-2 vegetables
        for (int i = 0; i < vegCount && i < vegetableMaterials.length; i++) {
          final veg =
              vegetableMaterials[_random.nextInt(vegetableMaterials.length)];
          if (!combination.contains(veg)) {
            combination.add(veg);
          }
        }
      }

      // Add grains/carbs
      if (rules.requiresCarbs && grainMaterials.isNotEmpty) {
        combination.add(grainMaterials[_random.nextInt(grainMaterials.length)]);
      }

      // Add spices/seasonings
      if (spiceMaterials.isNotEmpty) {
        final spiceCount = _random.nextInt(3) + 1; // 1-3 spices
        for (int i = 0; i < spiceCount && i < spiceMaterials.length; i++) {
          final spice = spiceMaterials[_random.nextInt(spiceMaterials.length)];
          if (!combination.contains(spice)) {
            combination.add(spice);
          }
        }
      }

      // Check if combination meets minimum requirements and hasn't been used
      if (combination.length >= rules.minMaterials &&
          combination.length <= rules.maxMaterials) {
        final combinationIds = combination.map((m) => m.id).toSet();
        if (!usedCombinations.contains(combinationIds)) {
          combinations.add(combination);
        }
      }
    }

    return combinations;
  }

  // Select the best material combination based on scoring
  List<Material> _selectBestCombination(
    List<List<Material>> combinations,
    MealType mealType,
  ) {
    if (combinations.isEmpty) return [];

    var bestCombination = combinations.first;
    var bestScore = _scoreCombination(bestCombination, mealType);

    for (final combination in combinations.skip(1)) {
      final score = _scoreCombination(combination, mealType);
      if (score > bestScore) {
        bestScore = score;
        bestCombination = combination;
      }
    }

    return bestCombination;
  }

  // Score a material combination based on various factors
  double _scoreCombination(List<Material> materials, MealType mealType) {
    double score = 0.0;

    // Base score for having materials
    score += materials.length * 10;

    // Bonus for category diversity
    final categories = materials.map((m) => m.category).toSet();
    score += categories.length * 15;

    // Meal type specific bonuses
    switch (mealType) {
      case MealType.breakfast:
        if (materials.any((m) => m.category == MaterialCategory.dairy)) {
          score += 20;
        }
        if (materials.any((m) => m.category == MaterialCategory.grains)) {
          score += 15;
        }
        break;
      case MealType.lunch:
      case MealType.dinner:
        if (materials.any(
          (m) =>
              m.category == MaterialCategory.meat ||
              m.category == MaterialCategory.seafood ||
              m.category == MaterialCategory.poultry,
        )) {
          score += 25;
        }
        if (materials.any((m) => m.category == MaterialCategory.vegetables)) {
          score += 20;
        }
        break;
      case MealType.snack:
        // Simpler combinations for snacks
        if (materials.length <= 3) {
          score += 10;
        }
        break;
    }

    // Penalty for too many materials
    if (materials.length > 7) {
      score -= (materials.length - 7) * 5;
    }

    return score;
  }

  // Create a meal object from selected materials
  Meal _createMealFromMaterials(List<Material> materials, MealType mealType) {
    final mealName = _generateMealName(materials, mealType);
    final description = _generateMealDescription(materials, mealType);
    final instructions = _generateMealInstructions(materials, mealType);
    final preparationTime = _estimatePreparationTime(materials, mealType);
    final calories = _estimateCalories(materials, mealType);

    return Meal(
      id: _uuid.v4(),
      name: mealName,
      description: description,
      materials: materials,
      mealType: mealType,
      preparationTime: preparationTime,
      instructions: instructions,
      createdAt: DateTime.now(),
      calories: calories,
      tags: _generateTags(materials, mealType),
    );
  }

  // Generate meal name based on materials and type
  String _generateMealName(List<Material> materials, MealType mealType) {
    final mainIngredients = materials
        .where(
          (m) =>
              m.category == MaterialCategory.meat ||
              m.category == MaterialCategory.seafood ||
              m.category == MaterialCategory.poultry ||
              m.category == MaterialCategory.vegetables,
        )
        .take(2)
        .map((m) => m.name)
        .toList();

    if (mainIngredients.isEmpty) {
      return '${mealType.displayName} Bowl';
    }

    final prefix = _getMealNamePrefix(mealType);
    if (mainIngredients.length == 1) {
      return '$prefix ${mainIngredients.first}';
    } else {
      return '$prefix ${mainIngredients.join(' and ')}';
    }
  }

  // Generate meal description
  String _generateMealDescription(List<Material> materials, MealType mealType) {
    final materialNames = materials.map((m) => m.name.toLowerCase()).toList();
    return 'A delicious ${mealType.displayName.toLowerCase()} featuring ${materialNames.join(', ')}.';
  }

  // Generate basic cooking instructions
  String _generateMealInstructions(
    List<Material> materials,
    MealType mealType,
  ) {
    final hasProtein = materials.any(
      (m) =>
          m.category == MaterialCategory.meat ||
          m.category == MaterialCategory.seafood ||
          m.category == MaterialCategory.poultry,
    );

    final hasVegetables = materials.any(
      (m) => m.category == MaterialCategory.vegetables,
    );

    final instructions = <String>[];

    if (hasProtein) {
      instructions.add('1. Season and cook the protein until done.');
    }

    if (hasVegetables) {
      instructions.add(
        '${instructions.length + 1}. Prepare and cook the vegetables.',
      );
    }

    instructions.add(
      '${instructions.length + 1}. Combine all ingredients and season to taste.',
    );
    instructions.add('${instructions.length + 1}. Serve hot and enjoy!');

    return instructions.join('\n');
  }

  // Estimate preparation time based on materials and complexity
  int _estimatePreparationTime(List<Material> materials, MealType mealType) {
    int baseTime = 15; // Base preparation time

    // Add time based on material categories
    for (final material in materials) {
      switch (material.category) {
        case MaterialCategory.meat:
        case MaterialCategory.poultry:
          baseTime += 20;
          break;
        case MaterialCategory.seafood:
          baseTime += 15;
          break;
        case MaterialCategory.vegetables:
          baseTime += 10;
          break;
        case MaterialCategory.grains:
          baseTime += 15;
          break;
        default:
          baseTime += 5;
      }
    }

    // Adjust for meal type
    switch (mealType) {
      case MealType.breakfast:
        baseTime = (baseTime * 0.8).round();
        break;
      case MealType.snack:
        baseTime = (baseTime * 0.5).round();
        break;
      default:
        break;
    }

    return baseTime.clamp(10, 120); // Between 10 and 120 minutes
  }

  // Estimate calories (basic estimation)
  int _estimateCalories(List<Material> materials, MealType mealType) {
    int calories = 0;

    for (final material in materials) {
      switch (material.category) {
        case MaterialCategory.meat:
        case MaterialCategory.poultry:
          calories += 200;
          break;
        case MaterialCategory.seafood:
          calories += 150;
          break;
        case MaterialCategory.dairy:
          calories += 100;
          break;
        case MaterialCategory.grains:
          calories += 150;
          break;
        case MaterialCategory.vegetables:
          calories += 30;
          break;
        default:
          calories += 10;
      }
    }

    // Adjust for meal type
    switch (mealType) {
      case MealType.breakfast:
        calories = (calories * 0.8).round();
        break;
      case MealType.snack:
        calories = (calories * 0.4).round();
        break;
      default:
        break;
    }

    return calories.clamp(100, 1000);
  }

  // Generate tags for meal
  List<String> _generateTags(List<Material> materials, MealType mealType) {
    final tags = <String>[mealType.displayName.toLowerCase()];

    // Add category-based tags
    final categories = materials.map((m) => m.category).toSet();
    for (final category in categories) {
      tags.add(category.displayName.toLowerCase());
    }

    // Add special tags
    if (materials.every(
      (m) =>
          m.category != MaterialCategory.meat &&
          m.category != MaterialCategory.seafood,
    )) {
      tags.add('vegetarian');
    }

    if (materials.every(
      (m) =>
          m.category != MaterialCategory.meat &&
          m.category != MaterialCategory.seafood &&
          m.category != MaterialCategory.dairy,
    )) {
      tags.add('vegan');
    }

    return tags;
  }

  // Get meal type specific rules
  _MealTypeRules _getMealTypeRules(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return _MealTypeRules(
          requiresProtein: false,
          requiresVegetables: false,
          requiresCarbs: true,
          minMaterials: 2,
          maxMaterials: 5,
        );
      case MealType.lunch:
      case MealType.dinner:
        return _MealTypeRules(
          requiresProtein: true,
          requiresVegetables: true,
          requiresCarbs: true,
          minMaterials: 3,
          maxMaterials: 7,
        );
      case MealType.snack:
        return _MealTypeRules(
          requiresProtein: false,
          requiresVegetables: false,
          requiresCarbs: false,
          minMaterials: 1,
          maxMaterials: 3,
        );
    }
  }

  // Get meal name prefix based on type
  String _getMealNamePrefix(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return 'Morning';
      case MealType.lunch:
        return 'Midday';
      case MealType.dinner:
        return 'Evening';
      case MealType.snack:
        return 'Quick';
    }
  }
}

// Helper class for meal type rules
class _MealTypeRules {
  final bool requiresProtein;
  final bool requiresVegetables;
  final bool requiresCarbs;
  final int minMaterials;
  final int maxMaterials;

  const _MealTypeRules({
    required this.requiresProtein,
    required this.requiresVegetables,
    required this.requiresCarbs,
    required this.minMaterials,
    required this.maxMaterials,
  });
}
