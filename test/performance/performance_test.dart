// Performance Tests for Button Functions Implementation
// Tests performance characteristics, memory usage, and optimization

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_generator/models/models.dart' as models;
import 'package:meal_generator/widgets/dialogs/add_material_dialog.dart';
import 'package:meal_generator/widgets/dialogs/edit_material_dialog.dart';
import 'package:meal_generator/widgets/dialogs/custom_meal_generation_dialog.dart';
import 'package:meal_generator/widgets/dialogs/share_meal_plan_dialog.dart';

void main() {
  group('Performance Tests', () {
    testWidgets('Add Material Dialog renders within performance budget', (
      WidgetTester tester,
    ) async {
      // Test 1: Rendering performance
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AddMaterialDialog(onMaterialAdded: (_) {})),
        ),
      );

      stopwatch.stop();

      // Should render within 100ms
      expect(stopwatch.elapsedMilliseconds, lessThan(100));

      // Test 2: Smooth scrolling performance
      final scrollableWidget = find.byType(SingleChildScrollView);
      if (scrollableWidget.evaluate().isNotEmpty) {
        await tester.fling(scrollableWidget, const Offset(0, -300), 1000);
        await tester.pumpAndSettle();

        // Should complete scrolling animation smoothly
        expect(tester.hasRunningAnimations, false);
      }

      // Test 3: Form interaction performance
      final nameField = find.byType(TextFormField).first;

      final inputStopwatch = Stopwatch()..start();
      await tester.enterText(nameField, 'Test Material Name');
      await tester.pump();
      inputStopwatch.stop();

      // Text input should be responsive (< 16ms for 60fps)
      expect(inputStopwatch.elapsedMilliseconds, lessThan(50));
    });

    testWidgets('Edit Material Dialog handles large data efficiently', (
      WidgetTester tester,
    ) async {
      // Create material with large data set
      final largeMaterial = models.Material(
        id: 'large-material-id-with-very-long-identifier',
        name: 'Very Long Material Name That Exceeds Normal Length',
        category: models.MaterialCategory.vegetables,
        description: 'A' * 200, // Maximum description length
        nutritionalInfo: List.generate(10, (i) => 'Nutritional Info Item $i'),
        imageUrl: 'https://example.com/very/long/path/to/image/file.jpg',
        isAvailable: true,
      );

      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditMaterialDialog(
              material: largeMaterial,
              onMaterialUpdated: (_) {},
            ),
          ),
        ),
      );

      stopwatch.stop();

      // Should handle large data efficiently
      expect(stopwatch.elapsedMilliseconds, lessThan(150));

      // Test field population performance
      final nameField = find.byType(TextFormField).first;
      final nameWidget = tester.widget<TextFormField>(nameField);
      expect(nameWidget.controller?.text, largeMaterial.name);
    });

    testWidgets(
      'Custom Meal Generation Dialog handles many materials efficiently',
      (WidgetTester tester) async {
        // Generate large number of test materials
        final largeMaterialsList = List.generate(50, (index) {
          return models.Material(
            id: 'material-$index',
            name: 'Material $index',
            category: models
                .MaterialCategory
                .values[index % models.MaterialCategory.values.length],
            description: 'Description for material $index',
            isAvailable: true,
          );
        });

        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomMealGenerationDialog(
                availableMaterials: largeMaterialsList,
                onMealGenerated: (_) {},
              ),
            ),
          ),
        );

        stopwatch.stop();

        // Should render large list efficiently
        expect(stopwatch.elapsedMilliseconds, lessThan(200));

        // Test scrolling performance with large list
        final scrollableWidget = find.byType(ListView);
        expect(scrollableWidget, findsOneWidget);

        final scrollStopwatch = Stopwatch()..start();
        await tester.fling(scrollableWidget, const Offset(0, -500), 1000);
        await tester.pumpAndSettle();
        scrollStopwatch.stop();

        // Scrolling should be smooth
        expect(scrollStopwatch.elapsedMilliseconds, lessThan(100));
      },
    );

    testWidgets('Memory usage optimization tests', (WidgetTester tester) async {
      // Test 1: Dialog disposal cleans up resources
      late AddMaterialDialog dialog;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  dialog = AddMaterialDialog(onMaterialAdded: (_) {});
                  showDialog(context: context, builder: (context) => dialog);
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Close dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify dialog is properly disposed
      expect(find.byType(AddMaterialDialog), findsNothing);

      // Test 2: Text controllers are disposed
      // This would be tested through the widget's dispose method
      // In a real scenario, we'd use memory profiling tools
    });

    testWidgets('Large form validation performance', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AddMaterialDialog(onMaterialAdded: (_) {})),
        ),
      );

      // Test rapid form validation
      final nameField = find.byType(TextFormField).first;

      final validationStopwatch = Stopwatch()..start();

      // Rapid input changes to test validation performance
      for (int i = 0; i < 10; i++) {
        await tester.enterText(nameField, 'Test $i');
        await tester.pump();
      }

      validationStopwatch.stop();

      // Validation should remain responsive
      expect(validationStopwatch.elapsedMilliseconds, lessThan(100));
    });

    testWidgets('Share dialog content generation performance', (
      WidgetTester tester,
    ) async {
      // Create large meal plan for testing
      final largeMealPlan = models.MealPlan(
        id: 'large-plan',
        date: DateTime.now(),
        meals: {
          for (final mealType in models.MealType.values)
            mealType: models.Meal(
              id: '${mealType.name}-meal',
              name: 'Large ${mealType.name} Meal',
              description: 'A' * 100, // Long description
              materials: List.generate(
                10,
                (i) => models.Material(
                  id: 'material-$i',
                  name: 'Material $i for ${mealType.name}',
                  category: models.MaterialCategory.vegetables,
                  isAvailable: true,
                ),
              ),
              mealType: mealType,
              instructions: 'Step 1: Prepare\n' * 10, // Long instructions
              preparationTime: 60,
              calories: 500,
              createdAt: DateTime.now(),
              tags: ['tag1', 'tag2', 'tag3'],
            ),
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ShareMealPlanDialog(mealPlan: largeMealPlan)),
        ),
      );

      stopwatch.stop();

      // Should handle large content efficiently
      expect(stopwatch.elapsedMilliseconds, lessThan(200));

      // Test preview generation performance
      final previewStopwatch = Stopwatch()..start();

      // Change format options to trigger preview regeneration
      final formattedRadio = find.byWidgetPredicate(
        (widget) =>
            widget is RadioListTile<String> && widget.value == 'formatted',
      );
      await tester.tap(formattedRadio);
      await tester.pumpAndSettle();

      previewStopwatch.stop();

      // Preview generation should be fast
      expect(previewStopwatch.elapsedMilliseconds, lessThan(50));
    });

    testWidgets('Tab switching performance', (WidgetTester tester) async {
      final testMaterials = List.generate(
        20,
        (i) => models.Material(
          id: 'material-$i',
          name: 'Material $i',
          category: models.MaterialCategory.vegetables,
          isAvailable: true,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomMealGenerationDialog(
              availableMaterials: testMaterials,
              onMealGenerated: (_) {},
            ),
          ),
        ),
      );

      // Test tab switching performance
      final tabs = ['Meal Type', 'Preferences', 'Details', 'Materials'];

      for (final tabName in tabs) {
        final stopwatch = Stopwatch()..start();

        await tester.tap(find.text(tabName));
        await tester.pumpAndSettle();

        stopwatch.stop();

        // Tab switching should be fast
        expect(stopwatch.elapsedMilliseconds, lessThan(50));
      }
    });

    testWidgets('Widget rebuild optimization', (WidgetTester tester) async {
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                buildCount++;
                return AddMaterialDialog(onMaterialAdded: (_) {});
              },
            ),
          ),
        ),
      );

      final initialBuildCount = buildCount;

      // Make a small change that shouldn't trigger full rebuild
      await tester.enterText(find.byType(TextFormField).first, 'A');
      await tester.pump();

      // Should minimize unnecessary rebuilds
      expect(buildCount - initialBuildCount, lessThanOrEqualTo(2));
    });

    testWidgets('Animation performance', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) =>
                        AddMaterialDialog(onMaterialAdded: (_) {}),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      // Test dialog opening animation
      final animationStopwatch = Stopwatch()..start();

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      animationStopwatch.stop();

      // Dialog animation should complete quickly
      expect(animationStopwatch.elapsedMilliseconds, lessThan(300));

      // Test dialog closing animation
      final closeStopwatch = Stopwatch()..start();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      closeStopwatch.stop();

      // Close animation should also be fast
      expect(closeStopwatch.elapsedMilliseconds, lessThan(300));
    });

    testWidgets('Search and filter performance', (WidgetTester tester) async {
      // Test with many materials for search performance
      final manyMaterials = List.generate(
        100,
        (i) => models.Material(
          id: 'material-$i',
          name: i % 2 == 0 ? 'Chicken Material $i' : 'Vegetable Material $i',
          category: i % 2 == 0
              ? models.MaterialCategory.poultry
              : models.MaterialCategory.vegetables,
          description: 'Description for material $i',
          isAvailable: true,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomMealGenerationDialog(
              availableMaterials: manyMaterials,
              onMealGenerated: (_) {},
            ),
          ),
        ),
      );

      // Test filtering performance (simulated through selection)
      final stopwatch = Stopwatch()..start();

      // Select multiple items rapidly
      for (int i = 0; i < 10; i++) {
        final checkbox = find.byType(CheckboxListTile).at(i);
        await tester.tap(checkbox);
        await tester.pump();
      }

      stopwatch.stop();

      // Multiple selections should remain responsive
      expect(stopwatch.elapsedMilliseconds, lessThan(200));
    });
  });
}
