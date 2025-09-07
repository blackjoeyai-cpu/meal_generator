// Unit tests for Meal model
// Tests meal creation, validation, serialization, and utility methods

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_generator/models/models.dart';

void main() {
  group('Meal Model Tests', () {
    late List<Material> testMaterials;
    late Meal testMeal;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime.now();
      testMaterials = [
        Material(
          id: 'chicken_breast',
          name: 'Chicken Breast',
          category: MaterialCategory.poultry,
          isAvailable: true,
        ),
        Material(
          id: 'rice',
          name: 'White Rice',
          category: MaterialCategory.grains,
          isAvailable: true,
        ),
        Material(
          id: 'broccoli',
          name: 'Broccoli',
          category: MaterialCategory.vegetables,
          isAvailable: true,
        ),
      ];

      testMeal = Meal(
        id: 'test_meal_001',
        name: 'Chicken Rice Bowl',
        description: 'Healthy chicken and rice with vegetables',
        materials: testMaterials,
        mealType: MealType.lunch,
        preparationTime: 30,
        instructions:
            'Cook rice, grill chicken, steam broccoli, combine and serve',
        createdAt: testDate,
        calories: 450,
        tags: ['healthy', 'protein', 'balanced'],
      );
    });

    test('Meal creation with valid data', () {
      expect(testMeal.id, 'test_meal_001');
      expect(testMeal.name, 'Chicken Rice Bowl');
      expect(testMeal.description, 'Healthy chicken and rice with vegetables');
      expect(testMeal.materials.length, 3);
      expect(testMeal.mealType, MealType.lunch);
      expect(testMeal.preparationTime, 30);
      expect(
        testMeal.instructions,
        'Cook rice, grill chicken, steam broccoli, combine and serve',
      );
      expect(testMeal.createdAt, testDate);
      expect(testMeal.calories, 450);
      expect(testMeal.tags.length, 3);
    });

    test('Meal JSON serialization', () {
      final json = testMeal.toJson();

      expect(json['id'], 'test_meal_001');
      expect(json['name'], 'Chicken Rice Bowl');
      expect(json['description'], 'Healthy chicken and rice with vegetables');
      expect(json['meal_type'], 'lunch');
      expect(json['preparation_time'], 30);
      expect(
        json['instructions'],
        'Cook rice, grill chicken, steam broccoli, combine and serve',
      );
      expect(json['calories'], 450);
      expect(json['materials'], isA<List>());
      expect(json['tags'], isA<List>());
      expect(json['created_at'], isA<String>());
    });

    test('Meal JSON deserialization', () {
      final json = testMeal.toJson();
      final mealFromJson = Meal.fromJson(json);

      expect(mealFromJson.id, testMeal.id);
      expect(mealFromJson.name, testMeal.name);
      expect(mealFromJson.description, testMeal.description);
      expect(mealFromJson.mealType, testMeal.mealType);
      expect(mealFromJson.preparationTime, testMeal.preparationTime);
      expect(mealFromJson.instructions, testMeal.instructions);
      expect(mealFromJson.calories, testMeal.calories);
      expect(mealFromJson.materials.length, testMeal.materials.length);
      expect(mealFromJson.tags.length, testMeal.tags.length);
    });

    test('Meal copyWith method', () {
      final updatedMeal = testMeal.copyWith(
        name: 'Updated Chicken Bowl',
        preparationTime: 45,
        calories: 500,
      );

      expect(updatedMeal.id, testMeal.id);
      expect(updatedMeal.name, 'Updated Chicken Bowl');
      expect(updatedMeal.preparationTime, 45);
      expect(updatedMeal.calories, 500);
      expect(updatedMeal.mealType, testMeal.mealType);
      expect(updatedMeal.description, testMeal.description);
    });

    test('Meal with minimal required fields', () {
      final minimalMeal = Meal(
        id: 'minimal_meal',
        name: 'Minimal Meal',
        description: 'Simple meal',
        materials: [testMaterials.first],
        mealType: MealType.snack,
        createdAt: testDate,
      );

      expect(minimalMeal.id, 'minimal_meal');
      expect(minimalMeal.preparationTime, 0);
      expect(minimalMeal.instructions, '');
      expect(minimalMeal.calories, null);
      expect(minimalMeal.tags, isEmpty);
      expect(minimalMeal.imageUrl, null);
    });

    test('Meal equality comparison', () {
      final identical1 = Meal(
        id: 'test_meal',
        name: 'Test Meal',
        description: 'Test description',
        materials: [testMaterials.first],
        mealType: MealType.lunch,
        createdAt: testDate,
      );

      final identical2 = Meal(
        id: 'test_meal',
        name: 'Test Meal',
        description: 'Test description',
        materials: [testMaterials.first],
        mealType: MealType.lunch,
        createdAt: testDate,
      );

      final different = Meal(
        id: 'different_meal',
        name: 'Different Meal',
        description: 'Different description',
        materials: [testMaterials.first],
        mealType: MealType.dinner,
        createdAt: testDate,
      );

      expect(identical1 == identical2, true);
      expect(identical1 == different, false);
      expect(identical1.hashCode == identical2.hashCode, true);
    });

    test('Meal tags handling', () {
      expect(testMeal.tags.contains('healthy'), true);
      expect(testMeal.tags.contains('protein'), true);
      expect(testMeal.tags.contains('balanced'), true);

      final mealWithoutTags = Meal(
        id: 'no_tags',
        name: 'Meal without tags',
        description: 'No tags meal',
        materials: [testMaterials.first],
        mealType: MealType.snack,
        createdAt: testDate,
      );

      expect(mealWithoutTags.tags, isEmpty);
    });

    test('Meal materials validation', () {
      expect(testMeal.materials.length, 3);
      expect(testMeal.materials.first.name, 'Chicken Breast');
      expect(testMeal.materials.last.name, 'Broccoli');

      // Test material availability
      final allAvailable = testMeal.materials.every((m) => m.isAvailable);
      expect(allAvailable, true);
    });
  });

  group('MealType Enum Tests', () {
    test('MealType values', () {
      final types = MealType.values;
      expect(types.contains(MealType.breakfast), true);
      expect(types.contains(MealType.lunch), true);
      expect(types.contains(MealType.dinner), true);
      expect(types.contains(MealType.snack), true);
    });

    test('MealType display names', () {
      expect(MealType.breakfast.displayName, 'Breakfast');
      expect(MealType.lunch.displayName, 'Lunch');
      expect(MealType.dinner.displayName, 'Dinner');
      expect(MealType.snack.displayName, 'Snack');
    });

    test('MealType emojis', () {
      expect(MealType.breakfast.emoji, '🌅');
      expect(MealType.lunch.emoji, '☀️');
      expect(MealType.dinner.emoji, '🌙');
      expect(MealType.snack.emoji, '🍿');
    });

    test('MealType time ranges', () {
      expect(MealType.breakfast.timeRange, '6:00 AM - 10:00 AM');
      expect(MealType.lunch.timeRange, '11:00 AM - 2:00 PM');
      expect(MealType.dinner.timeRange, '6:00 PM - 9:00 PM');
      expect(MealType.snack.timeRange, 'Anytime');
    });
  });
}
