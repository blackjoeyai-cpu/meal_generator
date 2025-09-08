// Integration tests for meal planning workflows
// Tests complete user workflows for meal planning functionality

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:meal_generator/models/models.dart' as models;
import 'package:meal_generator/providers/providers.dart';
import 'package:meal_generator/screens/main_screen.dart';

void main() {
  group('Meal Planning Integration Tests', () {
    late MaterialsProvider materialsProvider;
    late MealPlansProvider mealPlansProvider;
    late AppProvider appProvider;

    setUp(() {
      materialsProvider = MaterialsProvider();
      mealPlansProvider = MealPlansProvider();
      appProvider = AppProvider();
    });

    Widget createTestApp() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<MaterialsProvider>.value(
            value: materialsProvider,
          ),
          ChangeNotifierProvider<MealPlansProvider>.value(
            value: mealPlansProvider,
          ),
          ChangeNotifierProvider<AppProvider>.value(value: appProvider),
        ],
        child: const MaterialApp(home: MainScreen()),
      );
    }

    testWidgets('complete meal planning workflow', (WidgetTester tester) async {
      // Setup test materials
      final testMaterials = [
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
      ];

      // Pre-load materials
      for (final material in testMaterials) {
        await materialsProvider.addMaterial(material);
      }

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Step 1: Navigate to Materials tab
      await tester.tap(find.text('Materials'));
      await tester.pumpAndSettle();

      // Verify materials are displayed
      expect(find.text('Chicken Breast'), findsOneWidget);
      expect(find.text('Broccoli'), findsOneWidget);
      expect(find.text('Rice'), findsOneWidget);

      // Step 2: Add a new material
      await tester.tap(find.byTooltip('Add Material'));
      await tester.pumpAndSettle();

      // Fill in new material form
      await tester.enterText(find.byType(TextFormField).first, 'Olive Oil');

      // Select spices category
      final spicesRadio = find.byWidgetPredicate(
        (widget) =>
            widget is RadioListTile<models.MaterialCategory> &&
            widget.value == models.MaterialCategory.spices,
      );
      await tester.tap(spicesRadio);
      await tester.pumpAndSettle();

      // Save the material
      await tester.tap(find.text('Add Material'));
      await tester.pumpAndSettle();

      // Verify new material is added
      expect(find.text('Olive Oil'), findsOneWidget);

      // Step 3: Navigate to Meal Plans tab
      await tester.tap(find.text('Meal Plans'));
      await tester.pumpAndSettle();

      // Step 4: Generate a custom meal
      await tester.tap(find.text('Custom Generation'));
      await tester.pumpAndSettle();

      // Select materials in the dialog
      final chickenCheckbox = find.byWidgetPredicate(
        (widget) =>
            widget is CheckboxListTile &&
            widget.title is Text &&
            (widget.title as Text).data == 'Chicken Breast',
      );
      await tester.tap(chickenCheckbox);
      await tester.pumpAndSettle();

      // Navigate to meal type tab
      await tester.tap(find.text('Meal Type'));
      await tester.pumpAndSettle();

      // Select dinner
      final dinnerRadio = find.byWidgetPredicate(
        (widget) =>
            widget is RadioListTile<models.MealType> &&
            widget.value == models.MealType.dinner,
      );
      await tester.tap(dinnerRadio);
      await tester.pumpAndSettle();

      // Generate the meal (this would normally call the service)
      await tester.tap(find.text('Generate Meal'));
      await tester.pumpAndSettle();

      // Step 5: Verify meal plan creation
      // Note: In a real test, we would mock the meal generation service
      // For now, we'll verify the UI responds correctly

      // Step 6: Navigate to Calendar tab
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();

      // Verify calendar is displayed
      expect(find.byType(TableCalendar), findsOneWidget);
    });

    testWidgets('material management workflow', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Navigate to Materials tab
      await tester.tap(find.text('Materials'));
      await tester.pumpAndSettle();

      // Add a material
      await tester.tap(find.byTooltip('Add Material'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'Test Material');

      await tester.tap(find.text('Add Material'));
      await tester.pumpAndSettle();

      // Verify material appears
      expect(find.text('Test Material'), findsOneWidget);

      // Edit the material
      final moreButton = find.byIcon(Icons.more_vert);
      await tester.tap(moreButton);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      // Modify the material name
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'Modified Test Material');

      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      // Verify modification
      expect(find.text('Modified Test Material'), findsOneWidget);
      expect(find.text('Test Material'), findsNothing);

      // Toggle availability
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mark Unavailable'));
      await tester.pumpAndSettle();

      // Verify availability status changed
      expect(find.text('Unavailable'), findsOneWidget);
    });

    testWidgets('meal plan sharing workflow', (WidgetTester tester) async {
      // Setup a meal plan
      final testMealPlan = models.MealPlan(
        id: 'test-plan-1',
        date: DateTime.now(),
        meals: {
          models.MealType.lunch: models.Meal(
            id: 'test-meal-1',
            name: 'Test Lunch',
            description: 'A test lunch meal',
            materials: const [],
            mealType: models.MealType.lunch,
            createdAt: DateTime.now(),
          ),
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await mealPlansProvider.saveMealPlan(testMealPlan);

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Navigate to Meal Plans tab
      await tester.tap(find.text('Meal Plans'));
      await tester.pumpAndSettle();

      // Find and tap share button
      await tester.tap(find.byIcon(Icons.share));
      await tester.pumpAndSettle();

      // Verify share dialog opens
      expect(find.text('Share Meal Plan'), findsOneWidget);
      expect(find.text('Share Format:'), findsOneWidget);
      expect(find.text('Include in Share:'), findsOneWidget);

      // Test format selection
      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is RadioListTile<String> && widget.value == 'formatted',
        ),
      );
      await tester.pumpAndSettle();

      // Test content options
      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is CheckboxListTile &&
              widget.title is Text &&
              (widget.title as Text).data == 'Cooking Instructions',
        ),
      );
      await tester.pumpAndSettle();

      // Copy to clipboard
      await tester.tap(find.text('Copy'));
      await tester.pumpAndSettle();

      // Verify success message
      expect(find.text('Meal plan copied to clipboard'), findsOneWidget);
    });

    testWidgets('settings workflow', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Open settings
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Verify settings dialog
      expect(find.text('Settings'), findsAtLeastNWidgets(1));
      expect(find.text('General'), findsOneWidget);
      expect(find.text('Meal Planning'), findsOneWidget);
      expect(find.text('Dietary Restrictions'), findsOneWidget);

      // Toggle notification setting
      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is SwitchListTile &&
              widget.title is Text &&
              (widget.title as Text).data == 'Notifications',
        ),
      );
      await tester.pumpAndSettle();

      // Select dietary restrictions
      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is CheckboxListTile &&
              widget.title is Text &&
              (widget.title as Text).data == 'Vegetarian',
        ),
      );
      await tester.pumpAndSettle();

      // Save settings
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify success message
      expect(find.text('Settings saved successfully!'), findsOneWidget);
    });

    testWidgets('error handling workflow', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Try to add material with invalid data
      await tester.tap(find.text('Materials'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Add Material'));
      await tester.pumpAndSettle();

      // Submit empty form
      await tester.tap(find.text('Add Material'));
      await tester.pumpAndSettle();

      // Verify validation error
      expect(find.text('Material name is required'), findsOneWidget);

      // Enter invalid URL
      await tester.enterText(find.byType(TextFormField).first, 'Valid Name');

      await tester.enterText(find.byType(TextFormField).last, 'invalid-url');

      await tester.tap(find.text('Add Material'));
      await tester.pumpAndSettle();

      // Verify URL validation error
      expect(find.text('Please enter a valid URL'), findsOneWidget);
    });

    testWidgets('navigation and state persistence', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Navigate through all tabs
      await tester.tap(find.text('Materials'));
      await tester.pumpAndSettle();
      expect(find.text('No materials available'), findsOneWidget);

      await tester.tap(find.text('Meal Plans'));
      await tester.pumpAndSettle();
      expect(find.text('No Meal Plan Yet'), findsOneWidget);

      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();
      expect(find.byType(TableCalendar), findsOneWidget);

      // Verify tab state is maintained
      await tester.tap(find.text('Materials'));
      await tester.pumpAndSettle();
      expect(find.text('No materials available'), findsOneWidget);
    });
  });
}
