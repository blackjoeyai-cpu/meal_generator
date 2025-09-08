// Simplified button functionality tests that work with real providers
// Tests button behavior and basic functionality

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:meal_generator/screens/main_screen.dart';
import 'package:meal_generator/providers/providers.dart';

void main() {
  group('Button Functionality Tests', () {
    Widget createTestApp() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppProvider()),
          ChangeNotifierProvider(create: (_) => MaterialsProvider()),
          ChangeNotifierProvider(create: (_) => MealPlansProvider()),
        ],
        child: MaterialApp(home: const MainScreen(), theme: ThemeData.light()),
      );
    }

    group('FAB State Changes', () {
      testWidgets('FloatingActionButton changes based on selected tab', (
        tester,
      ) async {
        // Build the app
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Verify initial Calendar tab FAB
        expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
        expect(find.byTooltip('Generate Meal Plan'), findsOneWidget);

        // Switch to Materials tab
        await tester.tap(find.byIcon(Icons.kitchen));
        await tester.pumpAndSettle();

        // Verify Materials tab FAB
        expect(find.byIcon(Icons.add), findsOneWidget);
        expect(find.byTooltip('Add Material'), findsOneWidget);

        // Switch to Meal Plans tab
        await tester.tap(find.byIcon(Icons.restaurant));
        await tester.pumpAndSettle();

        // Verify Meal Plans tab FAB
        expect(find.byIcon(Icons.view_week), findsOneWidget);
        expect(find.byTooltip('Generate Weekly Plan'), findsOneWidget);

        // Switch back to Calendar tab
        await tester.tap(find.byIcon(Icons.calendar_today));
        await tester.pumpAndSettle();

        // Verify back to Calendar tab FAB
        expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
        expect(find.byTooltip('Generate Meal Plan'), findsOneWidget);
      });

      testWidgets('Tab switching maintains consistent FAB state', (
        tester,
      ) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Test rapid tab switching
        final tabIcons = [
          Icons.calendar_today,
          Icons.kitchen,
          Icons.restaurant,
        ];
        final expectedFABIcons = [
          Icons.auto_awesome,
          Icons.add,
          Icons.view_week,
        ];
        final expectedTooltips = [
          'Generate Meal Plan',
          'Add Material',
          'Generate Weekly Plan',
        ];

        for (int cycle = 0; cycle < 3; cycle++) {
          for (int i = 0; i < tabIcons.length; i++) {
            await tester.tap(find.byIcon(tabIcons[i]));
            await tester.pumpAndSettle();

            // Verify correct FAB for each tab
            expect(find.byIcon(expectedFABIcons[i]), findsOneWidget);
            expect(find.byTooltip(expectedTooltips[i]), findsOneWidget);
          }
        }
      });
    });

    group('Dialog Interactions', () {
      testWidgets('Generate meal plan dialog opens and closes correctly', (
        tester,
      ) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Open meal plan generation dialog
        await tester.tap(find.byIcon(Icons.auto_awesome));
        await tester.pumpAndSettle();

        // Verify dialog appears
        expect(find.text('Generate Meal Plan'), findsOneWidget);
        expect(
          find.text(
            'Generate a meal plan for the selected date using available materials?',
          ),
          findsOneWidget,
        );
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Generate'), findsOneWidget);

        // Close with Cancel button
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Verify dialog is closed
        expect(find.text('Generate Meal Plan'), findsNothing);
      });

      testWidgets('Weekly plan generation dialog works correctly', (
        tester,
      ) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Navigate to Meal Plans tab
        await tester.tap(find.byIcon(Icons.restaurant));
        await tester.pumpAndSettle();

        // Open weekly generation dialog
        await tester.tap(find.byIcon(Icons.view_week));
        await tester.pumpAndSettle();

        // Verify dialog appears
        expect(find.text('Generate Weekly Plan'), findsOneWidget);
        expect(
          find.text(
            'Generate meal plans for the entire week starting from the selected date?',
          ),
          findsOneWidget,
        );

        // Close with Cancel button
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Verify dialog is closed
        expect(find.text('Generate Weekly Plan'), findsNothing);
      });

      testWidgets('Settings menu dialog works correctly', (tester) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Open settings menu
        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pumpAndSettle();

        // Tap settings
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();

        // Verify settings dialog
        expect(find.text('Settings'), findsNWidgets(2)); // Title and menu item
        expect(
          find.text('Settings functionality coming soon!'),
          findsOneWidget,
        );

        // Close dialog
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
      });

      testWidgets('About dialog works correctly', (tester) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Open about menu
        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pumpAndSettle();

        // Tap about
        await tester.tap(find.text('About'));
        await tester.pumpAndSettle();

        // Verify about dialog
        expect(find.text('Meal Planner'), findsAtLeastNWidgets(1));
        expect(find.text('1.0.0'), findsOneWidget);

        // Close dialog
        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();
      });
    });

    group('Button Accessibility', () {
      testWidgets('All buttons have proper tooltips', (tester) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Test FAB tooltip
        final fabFinder = find.byType(FloatingActionButton);
        expect(fabFinder, findsOneWidget);

        final fab = tester.widget<FloatingActionButton>(fabFinder);
        expect(fab.tooltip, isNotNull);
        expect(fab.tooltip, isNotEmpty);

        // Test refresh button tooltip
        expect(find.byTooltip('Refresh'), findsOneWidget);
      });

      testWidgets('Button touch targets meet minimum size requirements', (
        tester,
      ) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Test FAB size (minimum 56dp for FAB)
        final fabSize = tester.getSize(find.byType(FloatingActionButton));
        expect(fabSize.width, greaterThanOrEqualTo(56.0));
        expect(fabSize.height, greaterThanOrEqualTo(56.0));

        // Test IconButton sizes (minimum 48dp)
        final refreshButtonSize = tester.getSize(find.byIcon(Icons.refresh));
        expect(refreshButtonSize.width, greaterThanOrEqualTo(48.0));
        expect(refreshButtonSize.height, greaterThanOrEqualTo(48.0));
      });

      testWidgets('Buttons respond to tap gestures correctly', (tester) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Test FAB tap
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        expect(find.text('Generate Meal Plan'), findsOneWidget);

        // Close dialog
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Test refresh button tap
        await tester.tap(find.byIcon(Icons.refresh));
        await tester.pumpAndSettle();

        // Test menu button tap
        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pumpAndSettle();
        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('About'), findsOneWidget);

        // Tap outside to close menu
        await tester.tapAt(const Offset(100, 100));
        await tester.pumpAndSettle();
      });
    });

    group('UI State Management', () {
      testWidgets('App bar shows correct title', (tester) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        expect(find.text('Meal Planner'), findsOneWidget);
      });

      testWidgets('Tab bar shows all three tabs', (tester) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.calendar_today), findsOneWidget);
        expect(find.byIcon(Icons.kitchen), findsOneWidget);
        expect(find.byIcon(Icons.restaurant), findsOneWidget);
        expect(find.text('Calendar'), findsOneWidget);
        expect(find.text('Materials'), findsOneWidget);
        expect(find.text('Meal Plans'), findsOneWidget);
      });

      testWidgets('Content area displays appropriate widgets for each tab', (
        tester,
      ) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Calendar tab should show calendar view
        expect(find.byType(TabBarView), findsOneWidget);

        // Switch to materials tab
        await tester.tap(find.byIcon(Icons.kitchen));
        await tester.pumpAndSettle();

        // Should still show TabBarView with materials content
        expect(find.byType(TabBarView), findsOneWidget);

        // Switch to meal plans tab
        await tester.tap(find.byIcon(Icons.restaurant));
        await tester.pumpAndSettle();

        // Should still show TabBarView with meal plans content
        expect(find.byType(TabBarView), findsOneWidget);
      });
    });

    group('Error Handling', () {
      testWidgets('App handles empty material generation gracefully', (
        tester,
      ) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Try to generate meal plan (should show no materials error if no materials exist)
        await tester.tap(find.byIcon(Icons.auto_awesome));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Generate'));
        await tester.pumpAndSettle();

        // Should show some feedback (either success or error about no materials)
        // The exact message depends on the current state of materials
        expect(find.byType(SnackBar), findsOneWidget);
      });

      testWidgets('Rapid button presses are handled gracefully', (
        tester,
      ) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Rapidly tap the FAB multiple times
        for (int i = 0; i < 5; i++) {
          await tester.tap(find.byType(FloatingActionButton));
          await tester.pump(const Duration(milliseconds: 100));
        }

        await tester.pumpAndSettle();

        // Should only show one dialog
        expect(find.text('Generate Meal Plan'), findsOneWidget);

        // Close dialog
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
      });
    });

    group('Integration Tests', () {
      testWidgets('Complete navigation workflow', (tester) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Test complete navigation through all tabs with FAB interactions
        await tester.tap(find.byIcon(Icons.auto_awesome));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.kitchen));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.restaurant));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.view_week));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Return to calendar
        await tester.tap(find.byIcon(Icons.calendar_today));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
      });
    });
  });
}
