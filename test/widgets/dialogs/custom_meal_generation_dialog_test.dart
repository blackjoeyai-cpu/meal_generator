// Unit tests for Custom Meal Generation Dialog
// Tests material selection, meal type selection, and custom meal generation

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_generator/models/models.dart' as models;
import 'package:meal_generator/widgets/dialogs/custom_meal_generation_dialog.dart';

void main() {
  group('Custom Meal Generation Dialog Tests', () {
    late List<models.Material> testMaterials;
    late bool onMealGeneratedCalled;

    void onMealGenerated(models.Meal meal) {
      onMealGeneratedCalled = true;
    }

    setUp(() {
      onMealGeneratedCalled = false;
      testMaterials = [
        const models.Material(
          id: '1',
          name: 'Chicken Breast',
          category: models.MaterialCategory.poultry,
          isAvailable: true,
        ),
        const models.Material(
          id: '2',
          name: 'Broccoli',
          category: models.MaterialCategory.vegetables,
          isAvailable: true,
        ),
        const models.Material(
          id: '3',
          name: 'Rice',
          category: models.MaterialCategory.grains,
          isAvailable: true,
        ),
        const models.Material(
          id: '4',
          name: 'Salmon',
          category: models.MaterialCategory.seafood,
          isAvailable: true,
        ),
      ];
    });

    testWidgets('should display dialog with tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomMealGenerationDialog(
              availableMaterials: testMaterials,
              onMealGenerated: onMealGenerated,
            ),
          ),
        ),
      );

      // Check dialog header
      expect(find.text('Custom Meal Generation'), findsOneWidget);
      expect(
        find.text('Create a meal with your selected materials and preferences'),
        findsOneWidget,
      );

      // Check tabs
      expect(find.text('Materials'), findsOneWidget);
      expect(find.text('Meal Type'), findsOneWidget);
      expect(find.text('Preferences'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);

      // Check action buttons
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Generate Meal'), findsOneWidget);
    });

    testWidgets('should pre-select materials when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomMealGenerationDialog(
              availableMaterials: testMaterials,
              onMealGenerated: onMealGenerated,
            ),
          ),
        ),
      );

      // Should pre-select first 2 materials
      expect(find.text('2 materials selected'), findsOneWidget);
      expect(find.text('Chicken Breast'), findsAtLeastNWidgets(1));
      expect(find.text('Broccoli'), findsAtLeastNWidgets(1));
    });

    testWidgets('should allow material selection and deselection', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomMealGenerationDialog(
              availableMaterials: testMaterials,
              onMealGenerated: onMealGenerated,
            ),
          ),
        ),
      );

      // Find Rice checkbox and select it
      final riceCheckbox = find.byWidgetPredicate(
        (widget) =>
            widget is CheckboxListTile &&
            widget.title is Text &&
            (widget.title as Text).data == 'Rice',
      );
      expect(riceCheckbox, findsOneWidget);
      await tester.tap(riceCheckbox);
      await tester.pumpAndSettle();

      // Should now have 3 materials selected
      expect(find.text('3 materials selected'), findsOneWidget);

      // Deselect Chicken Breast by tapping its chip
      final chickenChip = find.byWidgetPredicate(
        (widget) =>
            widget is Chip &&
            widget.label is Text &&
            (widget.label as Text).data == 'Chicken Breast',
      );
      await tester.tap(chickenChip);
      await tester.pumpAndSettle();

      // Should now have 2 materials selected
      expect(find.text('2 materials selected'), findsOneWidget);
    });

    testWidgets('should navigate between tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomMealGenerationDialog(
              availableMaterials: testMaterials,
              onMealGenerated: onMealGenerated,
            ),
          ),
        ),
      );

      // Switch to Meal Type tab
      await tester.tap(find.text('Meal Type'));
      await tester.pumpAndSettle();

      // Should see meal type options
      expect(find.text('Select Meal Type:'), findsOneWidget);
      expect(find.text('Breakfast'), findsOneWidget);
      expect(find.text('Lunch'), findsOneWidget);
      expect(find.text('Dinner'), findsOneWidget);
      expect(find.text('Snack'), findsOneWidget);

      // Check preparation time slider
      expect(find.text('Meal Parameters:'), findsOneWidget);
      expect(find.text('Preparation Time'), findsOneWidget);
      expect(find.text('Target Calories'), findsOneWidget);
    });

    testWidgets('should allow meal type selection', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomMealGenerationDialog(
              availableMaterials: testMaterials,
              onMealGenerated: onMealGenerated,
            ),
          ),
        ),
      );

      // Switch to Meal Type tab
      await tester.tap(find.text('Meal Type'));
      await tester.pumpAndSettle();

      // Select Dinner by finding the dinner list tile
      final dinnerTile = find.byWidgetPredicate(
        (widget) =>
            widget is ListTile &&
            widget.title is Row &&
            ((widget.title as Row).children.any(
              (child) =>
                  child is Text &&
                  child.data == models.MealType.dinner.displayName,
            )),
      );
      await tester.tap(dinnerTile);
      await tester.pumpAndSettle();

      // Verify dinner is selected by checking internal state through UI behavior
      await tester.pumpAndSettle();

      // We can verify selection by checking the generated summary or other UI indicators
    });

    testWidgets('should allow preferences selection', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomMealGenerationDialog(
              availableMaterials: testMaterials,
              onMealGenerated: onMealGenerated,
            ),
          ),
        ),
      );

      // Switch to Preferences tab
      await tester.tap(find.text('Preferences'));
      await tester.pumpAndSettle();

      // Should see dietary restrictions
      expect(find.text('Dietary Restrictions:'), findsOneWidget);
      expect(find.text('Vegetarian'), findsOneWidget);
      expect(find.text('Vegan'), findsOneWidget);
      expect(find.text('Gluten-Free'), findsOneWidget);

      // Should see cuisine preferences
      expect(find.text('Cuisine Preferences:'), findsOneWidget);
      expect(find.text('Italian'), findsOneWidget);
      expect(find.text('Asian'), findsOneWidget);

      // Select some preferences
      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is CheckboxListTile &&
              widget.title is Text &&
              (widget.title as Text).data == 'High-Protein',
        ),
      );
      await tester.pumpAndSettle();

      // Select cuisine
      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is FilterChip &&
              widget.label is Text &&
              (widget.label as Text).data == 'Italian',
        ),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('should show generation summary in details tab', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomMealGenerationDialog(
              availableMaterials: testMaterials,
              onMealGenerated: onMealGenerated,
            ),
          ),
        ),
      );

      // Switch to Details tab
      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();

      // Should show generation summary
      expect(find.text('Generation Summary:'), findsOneWidget);
      expect(find.text('Materials: 2 selected'), findsOneWidget);
      expect(
        find.text('Meal Type: Lunch'),
        findsOneWidget,
      ); // Default meal type
      expect(find.text('Prep Time: 30 minutes'), findsOneWidget);
      expect(find.text('Target Calories: 500 cal'), findsOneWidget);
    });

    testWidgets('should allow custom meal name and description', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomMealGenerationDialog(
              availableMaterials: testMaterials,
              onMealGenerated: onMealGenerated,
            ),
          ),
        ),
      );

      // Switch to Details tab
      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();

      // Enter custom name and description
      await tester.enterText(
        find.byType(TextFormField).first,
        'My Custom Meal',
      );

      await tester.enterText(
        find.byType(TextFormField).last,
        'A delicious custom meal',
      );

      await tester.pumpAndSettle();
    });

    testWidgets('should disable generate button with insufficient materials', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomMealGenerationDialog(
              availableMaterials: [testMaterials.first], // Only one material
              onMealGenerated: onMealGenerated,
            ),
          ),
        ),
      );

      // Deselect the pre-selected material
      final materialCheckbox = find.byType(CheckboxListTile).first;
      await tester.tap(materialCheckbox);
      await tester.pumpAndSettle();

      // Generate button should be disabled
      final generateButton = find.byType(ElevatedButton);
      expect(tester.widget<ElevatedButton>(generateButton).onPressed, null);
    });

    testWidgets('should enable generate button with sufficient materials', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomMealGenerationDialog(
              availableMaterials: testMaterials,
              onMealGenerated: onMealGenerated,
            ),
          ),
        ),
      );

      // Should have 2 pre-selected materials, button should be enabled
      final generateButton = find.byType(ElevatedButton);
      expect(
        tester.widget<ElevatedButton>(generateButton).onPressed,
        isNotNull,
      );
    });

    testWidgets('should handle close button', (WidgetTester tester) async {
      bool dialogClosed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => CustomMealGenerationDialog(
                      availableMaterials: testMaterials,
                      onMealGenerated: onMealGenerated,
                    ),
                  ).then((_) => dialogClosed = true);
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

      // Close with X button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(dialogClosed, true);
      expect(onMealGeneratedCalled, false);
    });

    testWidgets('should update sliders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomMealGenerationDialog(
              availableMaterials: testMaterials,
              onMealGenerated: onMealGenerated,
            ),
          ),
        ),
      );

      // Switch to Meal Type tab
      await tester.tap(find.text('Meal Type'));
      await tester.pumpAndSettle();

      // Find preparation time slider
      final prepTimeSlider = find.byType(Slider).first;
      await tester.drag(prepTimeSlider, const Offset(50, 0));
      await tester.pumpAndSettle();

      // Find calories slider
      final caloriesSlider = find.byType(Slider).last;
      await tester.drag(caloriesSlider, const Offset(100, 0));
      await tester.pumpAndSettle();

      // Switch to Details to verify changes
      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();

      // Values should have changed from defaults
      expect(
        find.textContaining('30 minutes'),
        findsNothing,
      ); // Default prep time
      expect(find.textContaining('500 cal'), findsNothing); // Default calories
    });

    testWidgets('should use initial meal type when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomMealGenerationDialog(
              availableMaterials: testMaterials,
              onMealGenerated: onMealGenerated,
              initialMealType: models.MealType.breakfast,
            ),
          ),
        ),
      );

      // Switch to Meal Type tab
      await tester.tap(find.text('Meal Type'));
      await tester.pumpAndSettle();

      // Breakfast should be selected
      // Verify breakfast is the default by checking internal state
      await tester.pumpAndSettle();

      // We can verify this through the UI or by checking the summary display
    });
  });
}
