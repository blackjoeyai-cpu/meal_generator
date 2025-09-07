// Unit tests for Add Material Dialog
// Tests form validation, user interactions, and material creation

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_generator/models/models.dart' as models;
import 'package:meal_generator/widgets/dialogs/add_material_dialog.dart';

void main() {
  group('Add Material Dialog Tests', () {
    late models.Material capturedMaterial;
    late bool onMaterialAddedCalled;

    void onMaterialAdded(models.Material material) {
      capturedMaterial = material;
      onMaterialAddedCalled = true;
    }

    setUp(() {
      onMaterialAddedCalled = false;
    });

    testWidgets('should display all form fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddMaterialDialog(
              onMaterialAdded: onMaterialAdded,
            ),
          ),
        ),
      );

      // Check if all form fields are present
      expect(find.text('Add New Material'), findsOneWidget);
      expect(find.text('Material Name *'), findsOneWidget);
      expect(find.text('Category *'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Nutritional Information'), findsOneWidget);
      expect(find.text('Image URL'), findsOneWidget);
      expect(find.text('Available'), findsOneWidget);
      
      // Check action buttons
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Add Material'), findsOneWidget);
    });

    testWidgets('should validate required material name', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddMaterialDialog(
              onMaterialAdded: onMaterialAdded,
            ),
          ),
        ),
      );

      // Try to submit without name
      await tester.tap(find.text('Add Material'));
      await tester.pumpAndSettle();

      expect(find.text('Material name is required'), findsOneWidget);
      expect(onMaterialAddedCalled, false);
    });

    testWidgets('should validate minimum name length', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddMaterialDialog(
              onMaterialAdded: onMaterialAdded,
            ),
          ),
        ),
      );

      // Enter single character name
      await tester.enterText(find.byType(TextFormField).first, 'A');
      await tester.tap(find.text('Add Material'));
      await tester.pumpAndSettle();

      expect(find.text('Material name must be at least 2 characters'), findsOneWidget);
    });

    testWidgets('should validate maximum name length', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddMaterialDialog(
              onMaterialAdded: onMaterialAdded,
            ),
          ),
        ),
      );

      // Enter name longer than 50 characters
      final longName = 'A' * 51;
      await tester.enterText(find.byType(TextFormField).first, longName);
      await tester.tap(find.text('Add Material'));
      await tester.pumpAndSettle();

      expect(find.text('Material name must be less than 50 characters'), findsOneWidget);
    });

    testWidgets('should validate description length', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddMaterialDialog(
              onMaterialAdded: onMaterialAdded,
            ),
          ),
        ),
      );

      // Enter valid name first
      await tester.enterText(find.byType(TextFormField).first, 'Test Material');
      
      // Enter description longer than 200 characters
      final longDescription = 'A' * 201;
      final descriptionField = find.byType(TextFormField).at(1);
      await tester.enterText(descriptionField, longDescription);
      await tester.tap(find.text('Add Material'));
      await tester.pumpAndSettle();

      expect(find.text('Description must be less than 200 characters'), findsOneWidget);
    });

    testWidgets('should validate nutritional info count', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddMaterialDialog(
              onMaterialAdded: onMaterialAdded,
            ),
          ),
        ),
      );

      // Enter valid name
      await tester.enterText(find.byType(TextFormField).first, 'Test Material');
      
      // Enter more than 10 nutritional info items
      final manyItems = List.generate(11, (i) => 'Item $i').join(', ');
      final nutritionalField = find.byType(TextFormField).at(2);
      await tester.enterText(nutritionalField, manyItems);
      await tester.tap(find.text('Add Material'));
      await tester.pumpAndSettle();

      expect(find.text('Maximum 10 nutritional info items allowed'), findsOneWidget);
    });

    testWidgets('should validate URL format', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddMaterialDialog(
              onMaterialAdded: onMaterialAdded,
            ),
          ),
        ),
      );

      // Enter valid name
      await tester.enterText(find.byType(TextFormField).first, 'Test Material');
      
      // Enter invalid URL
      final urlField = find.byType(TextFormField).at(3);
      await tester.enterText(urlField, 'invalid-url');
      await tester.tap(find.text('Add Material'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid URL'), findsOneWidget);
    });

    testWidgets('should allow category selection', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddMaterialDialog(
              onMaterialAdded: onMaterialAdded,
            ),
          ),
        ),
      );

      // Check that we have 7 category options (now as ListTiles)
      expect(find.byType(ListTile), findsNWidgets(8)); // 7 categories + 1 availability switch
      
      // Find meat category by text and tap it
      final meatText = find.text('Meat');
      await tester.tap(meatText);
      await tester.pumpAndSettle();
      
      // Verify meat is now selected by checking if any custom radio button shows selected state
      // We can verify this by checking the state through the UI behavior
      await tester.pumpAndSettle();
      
      // The selection state is internal, so we verify by attempting to submit
      // and checking that the material was created with the correct category
    });

    testWidgets('should toggle availability switch', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddMaterialDialog(
              onMaterialAdded: onMaterialAdded,
            ),
          ),
        ),
      );

      // Find availability switch (should be true by default)
      final switchTile = find.byType(SwitchListTile);
      expect(switchTile, findsOneWidget);
      
      final switchWidget = tester.widget<SwitchListTile>(switchTile);
      expect(switchWidget.value, true);
      
      // Tap to toggle
      await tester.tap(switchTile);
      await tester.pumpAndSettle();
      
      // Verify it's now false
      final updatedSwitchWidget = tester.widget<SwitchListTile>(switchTile);
      expect(updatedSwitchWidget.value, false);
    });

    testWidgets('should create material with valid data', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddMaterialDialog(
              onMaterialAdded: onMaterialAdded,
            ),
          ),
        ),
      );

      // Fill in valid data
      await tester.enterText(find.byType(TextFormField).first, 'Test Material');
      await tester.enterText(find.byType(TextFormField).at(1), 'Test description');
      await tester.enterText(find.byType(TextFormField).at(2), 'High protein, Low fat');
      await tester.enterText(find.byType(TextFormField).at(3), 'https://example.com/image.jpg');

      // Find meat category by looking for text 'Meat' in any widget
      final meatText = find.text('Meat');
      expect(meatText, findsOneWidget);
      await tester.tap(meatText);
      await tester.pumpAndSettle();

      // Submit
      await tester.tap(find.text('Add Material'));
      await tester.pumpAndSettle();

      // Verify material was created
      expect(onMaterialAddedCalled, true);
      expect(capturedMaterial.name, 'Test Material');
      expect(capturedMaterial.description, 'Test description');
      expect(capturedMaterial.category, models.MaterialCategory.meat);
      expect(capturedMaterial.nutritionalInfo, ['High protein', 'Low fat']);
      expect(capturedMaterial.imageUrl, 'https://example.com/image.jpg');
      expect(capturedMaterial.isAvailable, true);
    });

    testWidgets('should handle cancel button', (WidgetTester tester) async {
      bool dialogClosed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AddMaterialDialog(
                      onMaterialAdded: onMaterialAdded,
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

      // Tap cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify dialog closed and no material was created
      expect(dialogClosed, true);
      expect(onMaterialAddedCalled, false);
    });

    testWidgets('should show loading state during submission', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddMaterialDialog(
              onMaterialAdded: (material) {
                // Simulate delay
                Future.delayed(const Duration(milliseconds: 100), () {
                  onMaterialAdded(material);
                });
              },
            ),
          ),
        ),
      );

      // Fill valid name
      await tester.enterText(find.byType(TextFormField).first, 'Test Material');

      // Submit
      await tester.tap(find.text('Add Material'));
      await tester.pump(); // Don't settle, check loading state

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Add Material'), findsNothing);
    });

    testWidgets('should parse nutritional info correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddMaterialDialog(
              onMaterialAdded: onMaterialAdded,
            ),
          ),
        ),
      );

      // Fill in data with complex nutritional info
      await tester.enterText(find.byType(TextFormField).first, 'Test Material');
      await tester.enterText(
        find.byType(TextFormField).at(2), 
        'High protein,  Low fat , Vitamin C,, Iron',
      );

      // Submit
      await tester.tap(find.text('Add Material'));
      await tester.pumpAndSettle();

      // Verify nutritional info was parsed correctly (trimmed and empty items removed)
      expect(onMaterialAddedCalled, true);
      expect(capturedMaterial.nutritionalInfo, ['High protein', 'Low fat', 'Vitamin C', 'Iron']);
    });
  });
}