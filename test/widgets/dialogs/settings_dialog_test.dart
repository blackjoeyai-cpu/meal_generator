// Unit tests for Settings Dialog
// Tests settings functionality, validation, and persistence

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meal_generator/widgets/dialogs/settings_dialog.dart';

void main() {
  group('Settings Dialog Tests', () {
    setUp(() {
      // Reset SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('should display all settings sections', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SettingsDialog())),
      );

      // Wait for settings to load
      await tester.pumpAndSettle();

      // Check main sections
      expect(find.text('Settings'), findsAtLeastNWidgets(1));
      expect(find.text('General'), findsOneWidget);
      expect(find.text('Meal Planning'), findsOneWidget);
      expect(find.text('Dietary Restrictions'), findsOneWidget);
      expect(find.text('Data Management'), findsOneWidget);

      // Check general settings
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Dark Mode'), findsOneWidget);
      expect(find.text('Default Calendar View'), findsOneWidget);

      // Check meal planning settings
      expect(find.text('Default Portion Size'), findsOneWidget);

      // Check data management options
      expect(find.text('Export Data'), findsOneWidget);
      expect(find.text('Import Data'), findsOneWidget);
      expect(find.text('Clear All Data'), findsOneWidget);

      // Check action buttons
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('should load default settings correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SettingsDialog())),
      );

      await tester.pumpAndSettle();

      // Check default values
      final notificationSwitch = find.byWidgetPredicate(
        (widget) =>
            widget is SwitchListTile &&
            widget.title is Text &&
            (widget.title as Text).data == 'Notifications',
      );
      expect(tester.widget<SwitchListTile>(notificationSwitch).value, true);

      final darkModeSwitch = find.byWidgetPredicate(
        (widget) =>
            widget is SwitchListTile &&
            widget.title is Text &&
            (widget.title as Text).data == 'Dark Mode',
      );
      expect(tester.widget<SwitchListTile>(darkModeSwitch).value, false);

      // Check dropdown default values
      expect(find.text('Currently: month'), findsOneWidget);
      expect(find.text('Currently: medium'), findsOneWidget);
    });

    testWidgets('should toggle notification setting', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SettingsDialog())),
      );

      await tester.pumpAndSettle();

      // Find and toggle notification switch
      final notificationSwitch = find.byWidgetPredicate(
        (widget) =>
            widget is SwitchListTile &&
            widget.title is Text &&
            (widget.title as Text).data == 'Notifications',
      );

      // Initially should be true
      expect(tester.widget<SwitchListTile>(notificationSwitch).value, true);

      // Toggle it
      await tester.tap(notificationSwitch);
      await tester.pumpAndSettle();

      // Should now be false
      expect(tester.widget<SwitchListTile>(notificationSwitch).value, false);
    });

    testWidgets('should toggle dark mode setting', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SettingsDialog())),
      );

      await tester.pumpAndSettle();

      // Find and toggle dark mode switch
      final darkModeSwitch = find.byWidgetPredicate(
        (widget) =>
            widget is SwitchListTile &&
            widget.title is Text &&
            (widget.title as Text).data == 'Dark Mode',
      );

      // Initially should be false
      expect(tester.widget<SwitchListTile>(darkModeSwitch).value, false);

      // Toggle it
      await tester.tap(darkModeSwitch);
      await tester.pumpAndSettle();

      // Should now be true
      expect(tester.widget<SwitchListTile>(darkModeSwitch).value, true);
    });

    testWidgets('should change calendar view setting', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SettingsDialog())),
      );

      await tester.pumpAndSettle();

      // Find calendar view dropdown
      final calendarDropdown = find.byWidgetPredicate(
        (widget) => widget is DropdownButton<String> && widget.value == 'month',
      );

      // Tap to open dropdown
      await tester.tap(calendarDropdown);
      await tester.pumpAndSettle();

      // Select week option
      await tester.tap(find.text('WEEK'));
      await tester.pumpAndSettle();

      // Verify selection changed
      expect(find.text('Currently: week'), findsOneWidget);
    });

    testWidgets('should change portion size setting', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SettingsDialog())),
      );

      await tester.pumpAndSettle();

      // Find portion size dropdown
      final portionDropdown = find.byWidgetPredicate(
        (widget) =>
            widget is DropdownButton<String> && widget.value == 'medium',
      );

      // Tap to open dropdown
      await tester.tap(portionDropdown);
      await tester.pumpAndSettle();

      // Select large option
      await tester.tap(find.text('LARGE'));
      await tester.pumpAndSettle();

      // Verify selection changed
      expect(find.text('Currently: large'), findsOneWidget);
    });

    testWidgets('should select dietary restrictions', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SettingsDialog())),
      );

      await tester.pumpAndSettle();

      // Select vegetarian
      final vegetarianCheckbox = find.byWidgetPredicate(
        (widget) =>
            widget is CheckboxListTile &&
            widget.title is Text &&
            (widget.title as Text).data == 'Vegetarian',
      );
      await tester.tap(vegetarianCheckbox);
      await tester.pumpAndSettle();

      // Select gluten-free
      final glutenFreeCheckbox = find.byWidgetPredicate(
        (widget) =>
            widget is CheckboxListTile &&
            widget.title is Text &&
            (widget.title as Text).data == 'Gluten-Free',
      );
      await tester.tap(glutenFreeCheckbox);
      await tester.pumpAndSettle();

      // Should show selected restrictions as chips
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Chip &&
              widget.label is Text &&
              (widget.label as Text).data == 'Vegetarian',
        ),
        findsOneWidget,
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Chip &&
              widget.label is Text &&
              (widget.label as Text).data == 'Gluten-Free',
        ),
        findsOneWidget,
      );
    });

    testWidgets('should remove dietary restrictions via chips', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SettingsDialog())),
      );

      await tester.pumpAndSettle();

      // Select vegetarian first
      final vegetarianCheckbox = find.byWidgetPredicate(
        (widget) =>
            widget is CheckboxListTile &&
            widget.title is Text &&
            (widget.title as Text).data == 'Vegetarian',
      );
      await tester.tap(vegetarianCheckbox);
      await tester.pumpAndSettle();

      // Find the vegetarian chip and remove it
      final vegetarianChip = find.byWidgetPredicate(
        (widget) =>
            widget is Chip &&
            widget.label is Text &&
            (widget.label as Text).data == 'Vegetarian',
      );
      expect(vegetarianChip, findsOneWidget);

      // Tap the delete icon on the chip
      final chipWidget = tester.widget<Chip>(vegetarianChip);
      expect(chipWidget.onDeleted, isNotNull);
      await tester.tap(
        find.descendant(of: vegetarianChip, matching: find.byIcon(Icons.close)),
      );
      await tester.pumpAndSettle();

      // Chip should be removed
      expect(vegetarianChip, findsNothing);

      // Checkbox should be unchecked
      expect(tester.widget<CheckboxListTile>(vegetarianCheckbox).value, false);
    });

    testWidgets('should save settings to SharedPreferences', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SettingsDialog())),
      );

      await tester.pumpAndSettle();

      // Make some changes
      final notificationSwitch = find.byWidgetPredicate(
        (widget) =>
            widget is SwitchListTile &&
            widget.title is Text &&
            (widget.title as Text).data == 'Notifications',
      );
      await tester.tap(notificationSwitch);
      await tester.pumpAndSettle();

      // Select dietary restriction
      final vegetarianCheckbox = find.byWidgetPredicate(
        (widget) =>
            widget is CheckboxListTile &&
            widget.title is Text &&
            (widget.title as Text).data == 'Vegetarian',
      );
      await tester.tap(vegetarianCheckbox);
      await tester.pumpAndSettle();

      // Save settings
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify success message
      expect(find.text('Settings saved successfully!'), findsOneWidget);

      // Verify data was saved to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('notifications_enabled'), false);
      expect(
        prefs.getStringList('dietary_restrictions'),
        contains('Vegetarian'),
      );
    });

    testWidgets('should load saved settings from SharedPreferences', (
      WidgetTester tester,
    ) async {
      // Set up saved preferences
      SharedPreferences.setMockInitialValues({
        'notifications_enabled': false,
        'dark_mode_enabled': true,
        'default_calendar_view': 'week',
        'default_portion': 'large',
        'dietary_restrictions': ['Vegan', 'Gluten-Free'],
      });

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SettingsDialog())),
      );

      await tester.pumpAndSettle();

      // Verify loaded settings
      final notificationSwitch = find.byWidgetPredicate(
        (widget) =>
            widget is SwitchListTile &&
            widget.title is Text &&
            (widget.title as Text).data == 'Notifications',
      );
      expect(tester.widget<SwitchListTile>(notificationSwitch).value, false);

      final darkModeSwitch = find.byWidgetPredicate(
        (widget) =>
            widget is SwitchListTile &&
            widget.title is Text &&
            (widget.title as Text).data == 'Dark Mode',
      );
      expect(tester.widget<SwitchListTile>(darkModeSwitch).value, true);

      // Check dropdown values
      expect(find.text('Currently: week'), findsOneWidget);
      expect(find.text('Currently: large'), findsOneWidget);

      // Check dietary restrictions
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Chip &&
              widget.label is Text &&
              (widget.label as Text).data == 'Vegan',
        ),
        findsOneWidget,
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Chip &&
              widget.label is Text &&
              (widget.label as Text).data == 'Gluten-Free',
        ),
        findsOneWidget,
      );
    });

    testWidgets('should show data management dialogs', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SettingsDialog())),
      );

      await tester.pumpAndSettle();

      // Test export data
      await tester.tap(find.text('Export Data'));
      await tester.pumpAndSettle();

      expect(find.text('Export Data'), findsAtLeastNWidgets(1));
      expect(
        find.text('Export functionality will allow you to save'),
        findsOneWidget,
      );

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Test import data
      await tester.tap(find.text('Import Data'));
      await tester.pumpAndSettle();

      expect(find.text('Import Data'), findsAtLeastNWidgets(1));
      expect(
        find.text('Import functionality will allow you to restore'),
        findsOneWidget,
      );

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Test clear all data
      await tester.tap(find.text('Clear All Data'));
      await tester.pumpAndSettle();

      expect(find.text('Clear All Data'), findsAtLeastNWidgets(1));
      expect(
        find.text('Are you sure you want to delete all your meal plans'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsAtLeastNWidgets(1));
      expect(find.text('Clear All'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });

    testWidgets('should handle cancel action', (WidgetTester tester) async {
      bool dialogClosed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const SettingsDialog(),
                  ).then((_) => dialogClosed = true);
                },
                child: const Text('Open Settings'),
              ),
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Open Settings'));
      await tester.pumpAndSettle();

      // Make a change
      final notificationSwitch = find.byWidgetPredicate(
        (widget) =>
            widget is SwitchListTile &&
            widget.title is Text &&
            (widget.title as Text).data == 'Notifications',
      );
      await tester.tap(notificationSwitch);
      await tester.pumpAndSettle();

      // Cancel without saving
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog should close
      expect(dialogClosed, true);

      // Settings should not be saved
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('notifications_enabled'), isNull);
    });

    testWidgets('should show loading state while loading settings', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SettingsDialog())),
      );

      // Should show loading indicator initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for settings to load
      await tester.pumpAndSettle();

      // Loading indicator should be gone
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
