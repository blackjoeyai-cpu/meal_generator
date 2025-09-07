// Seed data service for initializing the app with default materials and meals
// Provides predefined ingredients and sample recipes for immediate use

import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

class SeedDataService {
  static final SeedDataService _instance = SeedDataService._internal();
  factory SeedDataService() => _instance;
  SeedDataService._internal();

  final MaterialService _materialService = MaterialService();
  final MealService _mealService = MealService();

  // Initialize seed data if not already present
  Future<void> initializeSeedData() async {
    try {
      // Check if data already exists
      final existingMaterials = await _materialService.getAllMaterials();
      if (existingMaterials.isNotEmpty) {
        return; // Data already exists
      }

      // Initialize materials first
      await _initializeMaterials();

      // Then initialize sample meals
      await _initializeSampleMeals();

      if (kDebugMode) {
        debugPrint('Seed data initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error initializing seed data: $e');
      }
      rethrow;
    }
  }

  // Initialize default materials
  Future<void> _initializeMaterials() async {
    final materials = _getDefaultMaterials();

    for (final material in materials) {
      await _materialService.addMaterial(material);
    }
  }

  // Initialize sample meals
  Future<void> _initializeSampleMeals() async {
    final allMaterials = await _materialService.getAllMaterials();
    final meals = _getSampleMeals(allMaterials);

    for (final meal in meals) {
      await _mealService.addMeal(meal);
    }
  }

  // Get default materials for the app
  List<Material> _getDefaultMaterials() {
    return [
      // Proteins
      Material(
        id: 'mat_chicken_breast',
        name: 'Chicken Breast',
        category: MaterialCategory.poultry,
        isAvailable: true,
        description: 'Boneless, skinless chicken breast',
        nutritionalInfo: ['High protein', 'Low carb', '165 calories per 100g'],
      ),
      Material(
        id: 'mat_salmon',
        name: 'Salmon Fillet',
        category: MaterialCategory.seafood,
        isAvailable: true,
        description: 'Fresh Atlantic salmon fillet',
        nutritionalInfo: [
          'Rich in omega-3',
          'High protein',
          '208 calories per 100g',
        ],
      ),
      Material(
        id: 'mat_ground_beef',
        name: 'Ground Beef',
        category: MaterialCategory.meat,
        isAvailable: true,
        description: 'Lean ground beef (85/15)',
        nutritionalInfo: [
          'High protein',
          'Rich in iron',
          '250 calories per 100g',
        ],
      ),
      Material(
        id: 'mat_eggs',
        name: 'Eggs',
        category: MaterialCategory.dairy,
        isAvailable: true,
        description: 'Large eggs',
        nutritionalInfo: [
          'Complete protein',
          'Rich in vitamins',
          '155 calories per 100g',
        ],
      ),

      // Vegetables
      Material(
        id: 'mat_broccoli',
        name: 'Broccoli',
        category: MaterialCategory.vegetables,
        isAvailable: true,
        description: 'Fresh broccoli crowns',
        nutritionalInfo: [
          'High in vitamin C',
          'Rich in fiber',
          '34 calories per 100g',
        ],
      ),
      Material(
        id: 'mat_carrots',
        name: 'Carrots',
        category: MaterialCategory.vegetables,
        isAvailable: true,
        description: 'Baby carrots',
        nutritionalInfo: [
          'Rich in beta-carotene',
          'Good fiber source',
          '41 calories per 100g',
        ],
      ),
      Material(
        id: 'mat_spinach',
        name: 'Spinach',
        category: MaterialCategory.vegetables,
        isAvailable: true,
        description: 'Fresh baby spinach',
        nutritionalInfo: [
          'Rich in iron',
          'High in vitamins',
          '23 calories per 100g',
        ],
      ),
      Material(
        id: 'mat_bell_peppers',
        name: 'Bell Peppers',
        category: MaterialCategory.vegetables,
        isAvailable: true,
        description: 'Mixed color bell peppers',
        nutritionalInfo: [
          'High vitamin C',
          'Antioxidants',
          '31 calories per 100g',
        ],
      ),
      Material(
        id: 'mat_onions',
        name: 'Yellow Onions',
        category: MaterialCategory.vegetables,
        isAvailable: true,
        description: 'Medium yellow onions',
        nutritionalInfo: [
          'Rich in antioxidants',
          'Good flavor base',
          '40 calories per 100g',
        ],
      ),
      Material(
        id: 'mat_tomatoes',
        name: 'Tomatoes',
        category: MaterialCategory.vegetables,
        isAvailable: true,
        description: 'Roma tomatoes',
        nutritionalInfo: [
          'Rich in lycopene',
          'High water content',
          '18 calories per 100g',
        ],
      ),

      // Grains and Starches
      Material(
        id: 'mat_rice',
        name: 'White Rice',
        category: MaterialCategory.grains,
        isAvailable: true,
        description: 'Long grain white rice',
        nutritionalInfo: [
          'Good carb source',
          'Quick energy',
          '130 calories per 100g',
        ],
      ),
      Material(
        id: 'mat_pasta',
        name: 'Spaghetti Pasta',
        category: MaterialCategory.grains,
        isAvailable: true,
        description: 'Whole wheat spaghetti',
        nutritionalInfo: [
          'Complex carbs',
          'Good fiber',
          '131 calories per 100g',
        ],
      ),
      Material(
        id: 'mat_quinoa',
        name: 'Quinoa',
        category: MaterialCategory.grains,
        isAvailable: true,
        description: 'Organic quinoa',
        nutritionalInfo: [
          'Complete protein',
          'Rich in minerals',
          '120 calories per 100g',
        ],
      ),
      Material(
        id: 'mat_bread',
        name: 'Whole Wheat Bread',
        category: MaterialCategory.grains,
        isAvailable: true,
        description: 'Whole grain bread',
        nutritionalInfo: ['Good fiber', 'B vitamins', '247 calories per 100g'],
      ),

      // Dairy
      Material(
        id: 'mat_milk',
        name: 'Milk',
        category: MaterialCategory.dairy,
        isAvailable: true,
        description: '2% milk',
        nutritionalInfo: [
          'Rich in calcium',
          'Good protein',
          '50 calories per 100ml',
        ],
      ),
      Material(
        id: 'mat_cheese',
        name: 'Cheddar Cheese',
        category: MaterialCategory.dairy,
        isAvailable: true,
        description: 'Sharp cheddar cheese',
        nutritionalInfo: [
          'High calcium',
          'Good protein',
          '403 calories per 100g',
        ],
      ),
      Material(
        id: 'mat_greek_yogurt',
        name: 'Greek Yogurt',
        category: MaterialCategory.dairy,
        isAvailable: true,
        description: 'Plain Greek yogurt',
        nutritionalInfo: ['High protein', 'Probiotics', '59 calories per 100g'],
      ),

      // Spices and Seasonings
      Material(
        id: 'mat_salt',
        name: 'Salt',
        category: MaterialCategory.spices,
        isAvailable: true,
        description: 'Sea salt',
        nutritionalInfo: ['Essential mineral', 'Flavor enhancer'],
      ),
      Material(
        id: 'mat_pepper',
        name: 'Black Pepper',
        category: MaterialCategory.spices,
        isAvailable: true,
        description: 'Ground black pepper',
        nutritionalInfo: ['Antioxidants', 'Flavor enhancer'],
      ),
      Material(
        id: 'mat_garlic',
        name: 'Garlic',
        category: MaterialCategory.vegetables,
        isAvailable: true,
        description: 'Fresh garlic bulbs',
        nutritionalInfo: [
          'Immune support',
          'Natural antibiotic',
          '149 calories per 100g',
        ],
      ),
      Material(
        id: 'mat_olive_oil',
        name: 'Olive Oil',
        category: MaterialCategory.spices,
        isAvailable: true,
        description: 'Extra virgin olive oil',
        nutritionalInfo: [
          'Healthy fats',
          'Vitamin E',
          '884 calories per 100ml',
        ],
      ),
    ];
  }

  // Get sample meals using available materials
  List<Meal> _getSampleMeals(List<Material> materials) {
    // Helper function to find material by ID
    Material? findMaterial(String id) {
      try {
        return materials.firstWhere((m) => m.id == id);
      } catch (e) {
        return null;
      }
    }

    final meals = <Meal>[];

    // Breakfast Meals
    final scrambledEggsMaterials = [
      findMaterial('mat_eggs'),
      findMaterial('mat_milk'),
      findMaterial('mat_cheese'),
      findMaterial('mat_salt'),
      findMaterial('mat_pepper'),
    ].where((m) => m != null).cast<Material>().toList();

    if (scrambledEggsMaterials.isNotEmpty) {
      meals.add(
        Meal(
          id: 'meal_scrambled_eggs',
          name: 'Scrambled Eggs with Cheese',
          description: 'Fluffy scrambled eggs with melted cheddar cheese',
          materials: scrambledEggsMaterials,
          mealType: MealType.breakfast,
          preparationTime: 15,
          instructions:
              'Beat 3 eggs with a splash of milk. Heat pan over medium heat. Add eggs and gently scramble. Add cheese just before eggs are set. Season with salt and pepper.',
          createdAt: DateTime.now(),
          calories: 320,
          tags: ['breakfast', 'protein', 'quick'],
        ),
      );
    }

    // Lunch Meals
    final chickenRiceMaterials = [
      findMaterial('mat_chicken_breast'),
      findMaterial('mat_rice'),
      findMaterial('mat_broccoli'),
      findMaterial('mat_garlic'),
      findMaterial('mat_olive_oil'),
      findMaterial('mat_salt'),
      findMaterial('mat_pepper'),
    ].where((m) => m != null).cast<Material>().toList();

    if (chickenRiceMaterials.isNotEmpty) {
      meals.add(
        Meal(
          id: 'meal_chicken_rice_bowl',
          name: 'Chicken and Rice Bowl',
          description: 'Grilled chicken breast with steamed rice and broccoli',
          materials: chickenRiceMaterials,
          mealType: MealType.lunch,
          preparationTime: 40,
          instructions:
              'Season chicken breast with salt, pepper, and garlic. Grill chicken for 6-7 minutes per side. Cook rice according to package instructions. Steam broccoli until tender. Slice chicken and serve over rice with broccoli.',
          createdAt: DateTime.now(),
          calories: 450,
          tags: ['lunch', 'protein', 'healthy'],
        ),
      );
    }

    // Dinner Meals
    final salmonQuinoaMaterials = [
      findMaterial('mat_salmon'),
      findMaterial('mat_quinoa'),
      findMaterial('mat_spinach'),
      findMaterial('mat_tomatoes'),
      findMaterial('mat_olive_oil'),
      findMaterial('mat_salt'),
      findMaterial('mat_pepper'),
    ].where((m) => m != null).cast<Material>().toList();

    if (salmonQuinoaMaterials.isNotEmpty) {
      meals.add(
        Meal(
          id: 'meal_salmon_quinoa',
          name: 'Herb-Crusted Salmon with Quinoa',
          description: 'Pan-seared salmon with quinoa and fresh vegetables',
          materials: salmonQuinoaMaterials,
          mealType: MealType.dinner,
          preparationTime: 40,
          instructions:
              'Cook quinoa according to package instructions. Season salmon with herbs, salt, and pepper. Heat olive oil in pan over medium-high heat. Cook salmon 4-5 minutes per side. Sauté spinach until wilted. Serve salmon over quinoa with spinach and tomatoes.',
          createdAt: DateTime.now(),
          calories: 520,
          tags: ['dinner', 'seafood', 'healthy'],
        ),
      );
    }

    // Pasta Dinner
    final pastaMaterials = [
      findMaterial('mat_pasta'),
      findMaterial('mat_ground_beef'),
      findMaterial('mat_tomatoes'),
      findMaterial('mat_onions'),
      findMaterial('mat_garlic'),
      findMaterial('mat_cheese'),
      findMaterial('mat_olive_oil'),
      findMaterial('mat_salt'),
      findMaterial('mat_pepper'),
    ].where((m) => m != null).cast<Material>().toList();

    if (pastaMaterials.isNotEmpty) {
      meals.add(
        Meal(
          id: 'meal_beef_pasta',
          name: 'Classic Beef Pasta',
          description: 'Spaghetti with ground beef and tomato sauce',
          materials: pastaMaterials,
          mealType: MealType.dinner,
          preparationTime: 45,
          instructions:
              'Cook pasta according to package directions. Brown ground beef in large pan. Add diced onions and garlic, cook until soft. Add tomatoes and simmer 15 minutes. Season with salt and pepper. Serve over pasta with cheese.',
          createdAt: DateTime.now(),
          calories: 480,
          tags: ['dinner', 'pasta', 'comfort'],
        ),
      );
    }

    // Snack
    final yogurtBowlMaterials = [
      findMaterial('mat_greek_yogurt'),
      findMaterial('mat_carrots'),
    ].where((m) => m != null).cast<Material>().toList();

    if (yogurtBowlMaterials.isNotEmpty) {
      meals.add(
        Meal(
          id: 'meal_yogurt_snack',
          name: 'Greek Yogurt with Carrots',
          description: 'Healthy snack with protein and vegetables',
          materials: yogurtBowlMaterials,
          mealType: MealType.snack,
          preparationTime: 5,
          instructions:
              'Serve Greek yogurt in a bowl. Cut carrots into sticks. Enjoy as a healthy snack.',
          createdAt: DateTime.now(),
          calories: 150,
          tags: ['snack', 'healthy', 'quick'],
        ),
      );
    }

    return meals;
  }

  // Force reinitialize data (for testing or reset)
  Future<void> resetAndReinitialize() async {
    try {
      // Note: This is a simplified reset for demo purposes
      // In a real implementation, you would clear the database
      if (kDebugMode) {
        debugPrint('Resetting seed data...');
      }

      // Reinitialize
      await initializeSeedData();

      if (kDebugMode) {
        debugPrint('Data reset and reinitialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error resetting data: $e');
      }
      rethrow;
    }
  }

  // Get statistics about seed data
  Future<Map<String, int>> getSeedDataStatistics() async {
    try {
      final materials = await _materialService.getAllMaterials();
      final meals = await _mealService.getAllMeals();

      final stats = <String, int>{
        'total_materials': materials.length,
        'total_meals': meals.length,
        'breakfast_meals': meals
            .where((m) => m.mealType == MealType.breakfast)
            .length,
        'lunch_meals': meals.where((m) => m.mealType == MealType.lunch).length,
        'dinner_meals': meals
            .where((m) => m.mealType == MealType.dinner)
            .length,
        'snack_meals': meals.where((m) => m.mealType == MealType.snack).length,
      };

      // Count materials by category
      for (final category in MaterialCategory.values) {
        final categoryCount = materials
            .where((m) => m.category == category)
            .length;
        stats['${category.name}_materials'] = categoryCount;
      }

      return stats;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting seed data statistics: $e');
      }
      return {};
    }
  }
}
