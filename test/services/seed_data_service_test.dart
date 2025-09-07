// Unit tests for SeedDataService
// Tests seed data initialization and default data creation

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_generator/services/services.dart';
import 'package:meal_generator/models/models.dart';

void main() {
  group('SeedDataService Tests', () {
    late SeedDataService seedDataService;

    setUp(() {
      seedDataService = SeedDataService();
    });

    test('SeedDataService singleton pattern', () {
      final instance1 = SeedDataService();
      final instance2 = SeedDataService();

      expect(identical(instance1, instance2), true);
    });

    test('SeedDataService initialization', () {
      expect(seedDataService, isNotNull);
    });

    // Note: These tests would normally require mocking the services
    // For a complete implementation, we'd use mockito or mocktail
    group('Default Data Validation', () {
      test('Default materials contain required categories', () {
        // This test would verify that default materials include
        // all material categories and have proper structure
        final categories = MaterialCategory.values;
        expect(categories.isNotEmpty, true);

        // Verify all categories exist
        for (final category in MaterialCategory.values) {
          expect(category.displayName, isNotEmpty);
          expect(category.emoji, isNotEmpty);
        }
      });

      test('Default meal types are available', () {
        final mealTypes = MealType.values;
        expect(mealTypes.length, 4);
        expect(mealTypes.contains(MealType.breakfast), true);
        expect(mealTypes.contains(MealType.lunch), true);
        expect(mealTypes.contains(MealType.dinner), true);
        expect(mealTypes.contains(MealType.snack), true);
      });
    });

    group('Data Structure Validation', () {
      test('Material structure validation', () {
        final testMaterial = Material(
          id: 'test_id',
          name: 'Test Material',
          category: MaterialCategory.vegetables,
          isAvailable: true,
        );

        expect(testMaterial.id, 'test_id');
        expect(testMaterial.name, 'Test Material');
        expect(testMaterial.category, MaterialCategory.vegetables);
        expect(testMaterial.isAvailable, true);
      });

      test('Meal structure validation', () {
        final testMaterial = Material(
          id: 'test_material',
          name: 'Test Material',
          category: MaterialCategory.vegetables,
          isAvailable: true,
        );

        final testMeal = Meal(
          id: 'test_meal',
          name: 'Test Meal',
          description: 'Test Description',
          materials: [testMaterial],
          mealType: MealType.lunch,
          createdAt: DateTime.now(),
        );

        expect(testMeal.id, 'test_meal');
        expect(testMeal.name, 'Test Meal');
        expect(testMeal.description, 'Test Description');
        expect(testMeal.materials.length, 1);
        expect(testMeal.mealType, MealType.lunch);
      });
    });

    group('Category Extensions', () {
      test('MaterialCategory extension methods', () {
        final category = MaterialCategory.poultry;
        expect(category.displayName, 'Poultry');
        expect(category.emoji, '🐔');
      });

      test('MealType extension methods', () {
        final mealType = MealType.breakfast;
        expect(mealType.displayName, 'Breakfast');
        expect(mealType.emoji, '🌅');
        expect(mealType.timeRange, '6:00 AM - 10:00 AM');
      });
    });
  });
}
