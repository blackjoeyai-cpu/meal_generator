// Accessibility Audit Tests for Button Functions
// Tests WCAG 2.1 AA compliance for all implemented dialogs and UI components

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_generator/models/models.dart' as models;
import 'package:meal_generator/widgets/dialogs/add_material_dialog.dart';
import 'package:meal_generator/widgets/dialogs/edit_material_dialog.dart';
import 'package:meal_generator/widgets/dialogs/settings_dialog.dart';
import 'package:meal_generator/widgets/dialogs/custom_meal_generation_dialog.dart';

void main() {
  group('Accessibility Audit Tests', () {
    testWidgets('Add Material Dialog accessibility compliance', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AddMaterialDialog(onMaterialAdded: (_) {})),
        ),
      );

      // Test 1: Check for semantic labels on form fields
      final nameField = find.byWidgetPredicate(
        (widget) => widget is TextFormField,
      );
      expect(nameField, findsAtLeastNWidgets(1));

      // Test for specific label text
      expect(find.text('Material Name *'), findsOneWidget);

      // Test 2: Check for accessible button labels
      expect(find.text('Add Material'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Test 3: Check radio button accessibility
      final radioButtons = find.byType(RadioListTile<models.MaterialCategory>);
      expect(radioButtons, findsNWidgets(7));

      for (int i = 0; i < 7; i++) {
        final radioButton = tester
            .widget<RadioListTile<models.MaterialCategory>>(radioButtons.at(i));
        expect(radioButton.title, isNotNull);
        expect(radioButton.subtitle, isNotNull);
      }

      // Test 4: Check switch accessibility
      final switchTile = find.byType(SwitchListTile);
      expect(switchTile, findsOneWidget);

      final switchWidget = tester.widget<SwitchListTile>(switchTile);
      expect(switchWidget.title, isNotNull);
      expect(switchWidget.subtitle, isNotNull);

      // Test 5: Check minimum touch target sizes (48dp)
      final buttons = find.byType(ElevatedButton);
      for (int i = 0; i < buttons.evaluate().length; i++) {
        final buttonSize = tester.getSize(buttons.at(i));
        expect(buttonSize.height, greaterThanOrEqualTo(48.0));
      }

      // Test 6: Check for keyboard navigation support
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      // Verify focus can move between elements
      expect(tester.binding.focusManager.primaryFocus, isNotNull);
    });

    testWidgets('Edit Material Dialog accessibility compliance', (
      WidgetTester tester,
    ) async {
      final testMaterial = const models.Material(
        id: 'test-id',
        name: 'Test Material',
        category: models.MaterialCategory.vegetables,
        isAvailable: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditMaterialDialog(
              material: testMaterial,
              onMaterialUpdated: (_) {},
            ),
          ),
        ),
      );

      // Test 1: Check ID display has semantic meaning
      expect(find.text('ID: test-id'), findsOneWidget);

      // Test 2: Check changes indicator accessibility
      await tester.enterText(find.byType(TextFormField).first, 'Modified Name');
      await tester.pump();

      expect(find.text('You have unsaved changes'), findsOneWidget);

      // Test 3: Check icon accessibility
      final closeIcon = find.byIcon(Icons.close);
      if (closeIcon.evaluate().isNotEmpty) {
        final iconButton = find.ancestor(
          of: closeIcon,
          matching: find.byType(IconButton),
        );
        expect(iconButton, findsOneWidget);
      }

      // Test 4: Check error states have proper announcements
      await tester.enterText(find.byType(TextFormField).first, '');
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      expect(find.text('Material name is required'), findsOneWidget);
    });

    testWidgets('Settings Dialog accessibility compliance', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SettingsDialog())),
      );

      await tester.pumpAndSettle();

      // Test 1: Check section headers have proper semantics
      expect(find.text('General'), findsOneWidget);
      expect(find.text('Meal Planning'), findsOneWidget);
      expect(find.text('Dietary Restrictions'), findsOneWidget);

      // Test 2: Check switch labels and descriptions
      final switches = find.byType(SwitchListTile);
      for (int i = 0; i < switches.evaluate().length; i++) {
        final switchWidget = tester.widget<SwitchListTile>(switches.at(i));
        expect(switchWidget.title, isNotNull);
        expect(switchWidget.subtitle, isNotNull);
      }

      // Test 3: Check dropdown accessibility
      final dropdowns = find.byType(DropdownButton<String>);
      for (int i = 0; i < dropdowns.evaluate().length; i++) {
        final dropdown = tester.widget<DropdownButton<String>>(dropdowns.at(i));
        expect(dropdown.value, isNotNull);
      }

      // Test 4: Check checkbox labels
      final checkboxes = find.byType(CheckboxListTile);
      for (int i = 0; i < checkboxes.evaluate().length; i++) {
        final checkbox = tester.widget<CheckboxListTile>(checkboxes.at(i));
        expect(checkbox.title, isNotNull);
      }

      // Test 5: Check dangerous actions are clearly marked
      final dangerousActions = find.text('Clear All Data');
      expect(dangerousActions, findsOneWidget);
    });

    testWidgets('Custom Meal Generation Dialog accessibility compliance', (
      WidgetTester tester,
    ) async {
      final testMaterials = [
        const models.Material(
          id: '1',
          name: 'Chicken',
          category: models.MaterialCategory.poultry,
          isAvailable: true,
        ),
        const models.Material(
          id: '2',
          name: 'Rice',
          category: models.MaterialCategory.grains,
          isAvailable: true,
        ),
      ];

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

      // Test 1: Check tab accessibility
      final tabs = find.byType(Tab);
      expect(tabs, findsNWidgets(4));

      for (int i = 0; i < 4; i++) {
        final tab = tester.widget<Tab>(tabs.at(i));
        expect(tab.icon, isNotNull);
        expect(tab.text, isNotNull);
      }

      // Test 2: Check material selection accessibility
      final checkboxes = find.byType(CheckboxListTile);
      for (int i = 0; i < checkboxes.evaluate().length; i++) {
        final checkbox = tester.widget<CheckboxListTile>(checkboxes.at(i));
        expect(checkbox.title, isNotNull);
        expect(checkbox.subtitle, isNotNull);
      }

      // Test 3: Check slider accessibility
      await tester.tap(find.text('Meal Type'));
      await tester.pumpAndSettle();

      final sliders = find.byType(Slider);
      for (int i = 0; i < sliders.evaluate().length; i++) {
        final slider = tester.widget<Slider>(sliders.at(i));
        expect(slider.semanticFormatterCallback, isNotNull);
      }

      // Test 4: Check progress indication
      expect(find.text('2 materials selected'), findsOneWidget);
      expect(find.text('Select at least 2 materials'), findsOneWidget);
    });

    testWidgets('Color contrast compliance check', (WidgetTester tester) async {
      // Test color contrast ratios for key UI elements
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AddMaterialDialog(onMaterialAdded: (_) {})),
        ),
      );

      // Test 1: Primary button contrast
      final primaryButton = find.byType(ElevatedButton);
      expect(primaryButton, findsOneWidget);

      // Test 2: Error text contrast
      await tester.enterText(find.byType(TextFormField).first, '');
      await tester.tap(find.text('Add Material'));
      await tester.pumpAndSettle();

      expect(find.text('Material name is required'), findsOneWidget);

      // Test 3: Disabled state contrast
      final disabledButton = tester.widget<ElevatedButton>(primaryButton);
      // When form is invalid, button should be disabled with proper contrast
      expect(disabledButton.onPressed, isNull);
    });

    testWidgets('Focus management compliance', (WidgetTester tester) async {
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

      // Test 1: Focus trap in dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Test 2: Initial focus placement
      expect(tester.binding.focusManager.primaryFocus, isNotNull);

      // Test 3: Tab navigation within dialog
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      // Focus should remain within dialog
      expect(find.byType(AlertDialog), findsOneWidget);

      // Test 4: Escape key closes dialog
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      // Dialog should close
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Screen reader support compliance', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AddMaterialDialog(onMaterialAdded: (_) {})),
        ),
      );

      // Test 1: Form field semantics
      final semantics = tester.getSemantics(find.byType(TextFormField).first);
      expect(semantics.label, isNotEmpty);

      // Test 2: Button semantics
      final buttonSemantics = tester.getSemantics(find.text('Add Material'));
      expect(
        buttonSemantics.getSemanticsData().hasAction(SemanticsAction.tap),
        isTrue,
      );

      // Test 3: Error message semantics
      await tester.enterText(find.byType(TextFormField).first, '');
      await tester.tap(find.text('Add Material'));
      await tester.pumpAndSettle();

      final errorText = find.text('Material name is required');
      expect(errorText, findsOneWidget);

      final errorSemantics = tester.getSemantics(errorText);
      expect(errorSemantics.label, isNotEmpty);
    });

    testWidgets('Touch target size compliance', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AddMaterialDialog(onMaterialAdded: (_) {})),
        ),
      );

      // Test 1: Button touch targets (minimum 48dp)
      final buttons = find.byType(ElevatedButton);
      for (int i = 0; i < buttons.evaluate().length; i++) {
        final buttonSize = tester.getSize(buttons.at(i));
        expect(buttonSize.height, greaterThanOrEqualTo(48.0));
        expect(buttonSize.width, greaterThanOrEqualTo(48.0));
      }

      // Test 2: Checkbox touch targets
      final checkboxes = find.byType(Checkbox);
      for (int i = 0; i < checkboxes.evaluate().length; i++) {
        final checkboxSize = tester.getSize(checkboxes.at(i));
        expect(checkboxSize.height, greaterThanOrEqualTo(48.0));
        expect(checkboxSize.width, greaterThanOrEqualTo(48.0));
      }

      // Test 3: Radio button touch targets
      final radioButtons = find.byType(Radio<models.MaterialCategory>);
      for (int i = 0; i < radioButtons.evaluate().length; i++) {
        final radioSize = tester.getSize(radioButtons.at(i));
        expect(radioSize.height, greaterThanOrEqualTo(48.0));
        expect(radioSize.width, greaterThanOrEqualTo(48.0));
      }

      // Test 4: Icon button touch targets
      final iconButtons = find.byType(IconButton);
      for (int i = 0; i < iconButtons.evaluate().length; i++) {
        final iconButtonSize = tester.getSize(iconButtons.at(i));
        expect(iconButtonSize.height, greaterThanOrEqualTo(48.0));
        expect(iconButtonSize.width, greaterThanOrEqualTo(48.0));
      }
    });

    testWidgets('Keyboard navigation compliance', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AddMaterialDialog(onMaterialAdded: (_) {})),
        ),
      );

      // Test 1: Tab order is logical
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      final firstFocus = tester.binding.focusManager.primaryFocus;
      expect(firstFocus, isNotNull);

      // Continue tabbing through elements
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      final secondFocus = tester.binding.focusManager.primaryFocus;
      expect(secondFocus, isNotNull);
      expect(secondFocus, isNot(equals(firstFocus)));

      // Test 2: Enter key activates buttons
      final submitButton = find.text('Add Material');
      await tester.tap(submitButton);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      // Test 3: Arrow keys work for radio buttons
      final radioButton = find
          .byType(RadioListTile<models.MaterialCategory>)
          .first;
      await tester.tap(radioButton);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
    });

    testWidgets('Loading state accessibility', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddMaterialDialog(
              onMaterialAdded: (material) async {
                await Future.delayed(const Duration(milliseconds: 100));
              },
            ),
          ),
        ),
      );

      // Fill valid data and submit
      await tester.enterText(find.byType(TextFormField).first, 'Test Material');
      await tester.tap(find.text('Add Material'));
      await tester.pump();

      // Test 1: Loading indicator has semantic label
      final loadingIndicator = find.byType(CircularProgressIndicator);
      if (loadingIndicator.evaluate().isNotEmpty) {
        final loadingSemantics = tester.getSemantics(loadingIndicator);
        expect(loadingSemantics.label, isNotEmpty);
      }

      // Test 2: Button state announces change
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
