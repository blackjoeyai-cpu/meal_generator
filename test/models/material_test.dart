// Unit tests for Material model
// Tests model creation, validation, serialization, and utility methods

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_generator/models/models.dart';

void main() {
  group('Material Model Tests', () {
    late Material testMaterial;

    setUp(() {
      testMaterial = Material(
        id: 'test_material_001',
        name: 'Test Chicken Breast',
        category: MaterialCategory.poultry,
        isAvailable: true,
        description: 'Fresh chicken breast for testing',
        nutritionalInfo: ['High protein', 'Low carb', '165 calories per 100g'],
        imageUrl: 'https://example.com/chicken.jpg',
      );
    });

    test('Material creation with valid data', () {
      expect(testMaterial.id, 'test_material_001');
      expect(testMaterial.name, 'Test Chicken Breast');
      expect(testMaterial.category, MaterialCategory.poultry);
      expect(testMaterial.isAvailable, true);
      expect(testMaterial.description, 'Fresh chicken breast for testing');
      expect(testMaterial.nutritionalInfo.length, 3);
      expect(testMaterial.imageUrl, 'https://example.com/chicken.jpg');
    });

    test('Material JSON serialization', () {
      final json = testMaterial.toJson();

      expect(json['id'], 'test_material_001');
      expect(json['name'], 'Test Chicken Breast');
      expect(json['category'], 'poultry');
      expect(json['is_available'], true);
      expect(json['description'], 'Fresh chicken breast for testing');
      expect(json['nutritional_info'], isA<List<String>>());
      expect(json['image_url'], 'https://example.com/chicken.jpg');
    });

    test('Material JSON deserialization', () {
      final json = testMaterial.toJson();
      final materialFromJson = Material.fromJson(json);

      expect(materialFromJson.id, testMaterial.id);
      expect(materialFromJson.name, testMaterial.name);
      expect(materialFromJson.category, testMaterial.category);
      expect(materialFromJson.isAvailable, testMaterial.isAvailable);
      expect(materialFromJson.description, testMaterial.description);
      expect(
        materialFromJson.nutritionalInfo.length,
        testMaterial.nutritionalInfo.length,
      );
      expect(materialFromJson.imageUrl, testMaterial.imageUrl);
    });

    test('Material copyWith method', () {
      final updatedMaterial = testMaterial.copyWith(
        name: 'Updated Chicken Breast',
        isAvailable: false,
        description: 'Updated description',
      );

      expect(updatedMaterial.id, testMaterial.id);
      expect(updatedMaterial.name, 'Updated Chicken Breast');
      expect(updatedMaterial.isAvailable, false);
      expect(updatedMaterial.description, 'Updated description');
      expect(updatedMaterial.category, testMaterial.category);
      expect(updatedMaterial.nutritionalInfo, testMaterial.nutritionalInfo);
    });

    test('Material category validation', () {
      for (final category in MaterialCategory.values) {
        final material = Material(
          id: 'test_${category.name}',
          name: 'Test ${category.name}',
          category: category,
          isAvailable: true,
        );

        expect(material.category, category);
        expect(material.toJson()['category'], category.name);
      }
    });

    test('Material equality comparison', () {
      final identical1 = Material(
        id: 'test_001',
        name: 'Test Item',
        category: MaterialCategory.vegetables,
        isAvailable: true,
      );

      final identical2 = Material(
        id: 'test_001',
        name: 'Test Item',
        category: MaterialCategory.vegetables,
        isAvailable: true,
      );

      final different = Material(
        id: 'test_002',
        name: 'Different Item',
        category: MaterialCategory.vegetables,
        isAvailable: true,
      );

      expect(identical1 == identical2, true);
      expect(identical1 == different, false);
      expect(identical1.hashCode == identical2.hashCode, true);
    });

    test('Material nutritional info handling', () {
      expect(testMaterial.nutritionalInfo.contains('High protein'), true);
      expect(testMaterial.nutritionalInfo.contains('Low carb'), true);
      expect(
        testMaterial.nutritionalInfo.contains('165 calories per 100g'),
        true,
      );

      final materialWithoutNutrition = Material(
        id: 'no_nutrition',
        name: 'Item without nutrition',
        category: MaterialCategory.spices,
        isAvailable: true,
      );

      expect(materialWithoutNutrition.nutritionalInfo, isEmpty);
    });

    test('Material validation edge cases', () {
      // Test material with minimal required fields
      final minimalMaterial = Material(
        id: 'minimal',
        name: 'Minimal Item',
        category: MaterialCategory.vegetables,
        isAvailable: true,
      );

      expect(minimalMaterial.id, 'minimal');
      expect(minimalMaterial.description, null);
      expect(minimalMaterial.imageUrl, null);
      expect(minimalMaterial.nutritionalInfo, isEmpty);
    });

    test('Material availability states', () {
      final availableMaterial = Material(
        id: 'available',
        name: 'Available Item',
        category: MaterialCategory.meat,
        isAvailable: true,
      );

      final unavailableMaterial = Material(
        id: 'unavailable',
        name: 'Unavailable Item',
        category: MaterialCategory.meat,
        isAvailable: false,
      );

      expect(availableMaterial.isAvailable, true);
      expect(unavailableMaterial.isAvailable, false);
    });
  });

  group('MaterialCategory Enum Tests', () {
    test('MaterialCategory values', () {
      final categories = MaterialCategory.values;
      expect(categories.contains(MaterialCategory.meat), true);
      expect(categories.contains(MaterialCategory.seafood), true);
      expect(categories.contains(MaterialCategory.poultry), true);
      expect(categories.contains(MaterialCategory.vegetables), true);
      expect(categories.contains(MaterialCategory.grains), true);
      expect(categories.contains(MaterialCategory.dairy), true);
      expect(categories.contains(MaterialCategory.spices), true);
    });

    test('MaterialCategory string conversion', () {
      expect(MaterialCategory.meat.name, 'meat');
      expect(MaterialCategory.seafood.name, 'seafood');
      expect(MaterialCategory.poultry.name, 'poultry');
      expect(MaterialCategory.vegetables.name, 'vegetables');
      expect(MaterialCategory.grains.name, 'grains');
      expect(MaterialCategory.dairy.name, 'dairy');
      expect(MaterialCategory.spices.name, 'spices');
    });
  });
}
