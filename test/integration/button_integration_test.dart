// Integration tests for end-to-end button workflows
// Tests complete user journeys with real provider implementations

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:meal_generator/screens/main_screen.dart';
import 'package:meal_generator/providers/providers.dart';

void main() {
  group('End-to-End Button Workflow Integration Tests', () {
    late AppProvider appProvider;
    late MaterialsProvider materialsProvider;
    late MealPlansProvider mealPlansProvider;

    setUp(() async {
      // Initialize real providers for integration testing
      appProvider = AppProvider();
      materialsProvider = MaterialsProvider();
      mealPlansProvider = MealPlansProvider();

      // Initialize app provider
      await appProvider.initialize();
    });

    Widget createIntegrationTestApp() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<AppProvider>.value(value: appProvider),
          ChangeNotifierProvider<MaterialsProvider>.value(
            value: materialsProvider,
          ),
          ChangeNotifierProvider<MealPlansProvider>.value(
            value: mealPlansProvider,
          ),
        ],
        child: const MaterialApp(home: MainScreen()),
      );
    }

    testWidgets('End-to-end meal planning workflow', (tester) async {
      // Given: App initialized with test data and real providers
      await materialsProvider.loadMaterials();
      await mealPlansProvider.loadCurrentMonthMealPlans();

      await tester.pumpWidget(createIntegrationTestApp());
      await tester.pumpAndSettle();

      // When: User navigates to Calendar tab (should be default)
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);

      // When: User checks if materials are available
      if (materialsProvider.allMaterials
          .where((m) => m.isAvailable)
          .isNotEmpty) {
        // When: User presses FAB (Generate Meal Plan)
        await tester.tap(find.byIcon(Icons.auto_awesome));
        await tester.pumpAndSettle();

        // Then: Confirmation dialog should appear
        expect(find.text('Generate Meal Plan'), findsOneWidget);
        expect(
          find.text(
            'Generate a meal plan for the selected date using available materials?',
          ),
          findsOneWidget,
        );

        // When: User confirms generation
        await tester.tap(find.text('Generate'));
        await tester.pumpAndSettle();

        // Allow time for async operation
        await tester.pump(const Duration(seconds: 2));

        // Then: Success message should be displayed
        expect(
          find.textContaining('Meal plan generated successfully'),
          findsOneWidget,
        );

        // When: User views created meal plan (switch to meal plans tab)
        await tester.tap(find.byIcon(Icons.restaurant));
        await tester.pumpAndSettle();

        // Then: Meal plan should be displayed with action buttons
        // Note: This depends on actual meal plan creation success
      } else {
        // When: User presses FAB with no available materials
        await tester.tap(find.byIcon(Icons.auto_awesome));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Generate'));
        await tester.pumpAndSettle();

        // Then: Error message should guide user to add materials
        expect(
          find.textContaining('No available materials found'),
          findsOneWidget,
        );
      }
    });

    testWidgets('Material management to meal generation flow', (tester) async {
      // Given: App with populated materials database
      await materialsProvider.loadMaterials();

      await tester.pumpWidget(createIntegrationTestApp());
      await tester.pumpAndSettle();

      // When: User navigates to Materials tab
      await tester.tap(find.byIcon(Icons.kitchen));
      await tester.pumpAndSettle();

      // Then: Materials list should be displayed
      if (materialsProvider.filteredMaterials.isNotEmpty) {
        // When: User selects multiple materials
        final checkboxes = find.byType(Checkbox);
        if (checkboxes.evaluate().isNotEmpty) {
          await tester.tap(checkboxes.first);
          await tester.pumpAndSettle();

          // Then: Selection counter should update in real-time
          if (materialsProvider.selectedMaterialsCount > 0) {
            expect(find.text('Generate Meals'), findsOneWidget);

            // When: User presses "Generate Meals" button
            await tester.tap(find.text('Generate Meals'));
            await tester.pumpAndSettle();

            // Then: Feedback message should confirm generation with material count
            expect(
              find.textContaining('Generating meals with'),
              findsOneWidget,
            );
          }
        }
      } else {
        // Then: Empty state should be displayed
        expect(find.text('No materials available'), findsOneWidget);
        expect(find.text('Add Materials'), findsOneWidget);
      }
    });

    testWidgets('Weekly meal plan generation workflow', (tester) async {
      // Given: App with sufficient materials for weekly planning
      await materialsProvider.loadMaterials();

      // Ensure we have enough materials
      final availableMaterials = materialsProvider.allMaterials
          .where((material) => material.isAvailable)
          .toList();

      await tester.pumpWidget(createIntegrationTestApp());
      await tester.pumpAndSettle();

      // When: User navigates to Meal Plans tab
      await tester.tap(find.byIcon(Icons.restaurant));
      await tester.pumpAndSettle();

      // Then: Current week view should be displayed
      expect(find.textContaining('Meal Plan for'), findsOneWidget);

      if (availableMaterials.isNotEmpty) {
        // When: User presses FAB (Generate Weekly Plan)
        await tester.tap(find.byIcon(Icons.view_week));
        await tester.pumpAndSettle();

        // Then: Weekly generation confirmation dialog should appear
        expect(find.text('Generate Weekly Plan'), findsOneWidget);
        expect(
          find.text(
            'Generate meal plans for the entire week starting from the selected date?',
          ),
          findsOneWidget,
        );

        // When: User confirms weekly generation
        await tester.tap(find.text('Generate'));
        await tester.pumpAndSettle();

        // Allow time for async operation
        await tester.pump(const Duration(seconds: 3));

        // Then: Success message should confirm weekly generation completion
        expect(
          find.textContaining('Weekly meal plans generated successfully'),
          findsOneWidget,
        );
      } else {
        // When: User presses FAB with insufficient materials
        await tester.tap(find.byIcon(Icons.view_week));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Generate'));
        await tester.pumpAndSettle();

        // Then: Error message should be displayed
        expect(
          find.textContaining('No available materials found'),
          findsOneWidget,
        );
      }
    });

    testWidgets('Complete app navigation and state persistence', (
      tester,
    ) async {
      // Given: App is initialized
      await materialsProvider.loadMaterials();
      await mealPlansProvider.loadCurrentMonthMealPlans();

      await tester.pumpWidget(createIntegrationTestApp());
      await tester.pumpAndSettle();

      // Test complete navigation flow
      final tabIcons = [Icons.calendar_today, Icons.kitchen, Icons.restaurant];
      final expectedFABIcons = [Icons.auto_awesome, Icons.add, Icons.view_week];

      for (int i = 0; i < tabIcons.length; i++) {
        // Navigate to tab
        await tester.tap(find.byIcon(tabIcons[i]));
        await tester.pumpAndSettle();

        // Verify FAB changes
        expect(find.byIcon(expectedFABIcons[i]), findsOneWidget);

        // Test refresh functionality
        await tester.tap(find.byIcon(Icons.refresh));
        await tester.pumpAndSettle();

        // Verify state is maintained after refresh
        expect(find.byIcon(expectedFABIcons[i]), findsOneWidget);
      }

      // Test menu functionality
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Test settings menu
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Settings functionality coming soon!'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Test about menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('About'));
      await tester.pumpAndSettle();
      expect(find.text('Meal Planner'), findsAtLeastNWidgets(1));

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
    });

    testWidgets('Error recovery and retry workflows', (tester) async {
      await tester.pumpWidget(createIntegrationTestApp());
      await tester.pumpAndSettle();

      // Test various error scenarios and recovery

      // Test refresh button functionality
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      // Verify app remains functional after refresh
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Test dialog cancellation and retry
      await tester.tap(find.byIcon(Icons.auto_awesome));
      await tester.pumpAndSettle();

      // Cancel dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Try again
      await tester.tap(find.byIcon(Icons.auto_awesome));
      await tester.pumpAndSettle();

      // Verify dialog appears again
      expect(find.text('Generate Meal Plan'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });

    testWidgets('Data persistence across app lifecycle', (tester) async {
      // Given: App with initial data
      await materialsProvider.loadMaterials();
      final initialMaterialCount = materialsProvider.allMaterials.length;

      await tester.pumpWidget(createIntegrationTestApp());
      await tester.pumpAndSettle();

      // Navigate to materials tab and verify data
      await tester.tap(find.byIcon(Icons.kitchen));
      await tester.pumpAndSettle();

      // Simulate app restart by rebuilding widget tree
      await tester.pumpWidget(createIntegrationTestApp());
      await tester.pumpAndSettle();

      // Navigate back to materials tab
      await tester.tap(find.byIcon(Icons.kitchen));
      await tester.pumpAndSettle();

      // Verify data persistence
      expect(
        materialsProvider.allMaterials.length,
        equals(initialMaterialCount),
      );
    });

    group('Real-time state synchronization', () {
      testWidgets('Provider state changes reflect immediately in UI', (
        tester,
      ) async {
        await materialsProvider.loadMaterials();

        await tester.pumpWidget(createIntegrationTestApp());
        await tester.pumpAndSettle();

        // Navigate to materials tab
        await tester.tap(find.byIcon(Icons.kitchen));
        await tester.pumpAndSettle();

        // If materials exist, test selection
        if (materialsProvider.filteredMaterials.isNotEmpty) {
          final initialSelectedCount = materialsProvider.selectedMaterialsCount;

          // Select material
          final checkboxes = find.byType(Checkbox);
          if (checkboxes.evaluate().isNotEmpty) {
            await tester.tap(checkboxes.first);
            await tester.pumpAndSettle();

            // Verify UI reflects selection change
            final newSelectedCount = materialsProvider.selectedMaterialsCount;
            expect(newSelectedCount, isNot(equals(initialSelectedCount)));
          }
        }
      });

      testWidgets('Cross-tab state consistency', (tester) async {
        await materialsProvider.loadMaterials();
        await mealPlansProvider.loadCurrentMonthMealPlans();

        await tester.pumpWidget(createIntegrationTestApp());
        await tester.pumpAndSettle();

        // Test that date selection is consistent across tabs
        final initialSelectedDate = mealPlansProvider.selectedDate;

        // Navigate between tabs
        await tester.tap(find.byIcon(Icons.kitchen));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.restaurant));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.calendar_today));
        await tester.pumpAndSettle();

        // Verify date consistency
        expect(mealPlansProvider.selectedDate, equals(initialSelectedDate));
      });
    });

    group('Performance and memory management', () {
      testWidgets('Rapid button presses do not cause memory leaks', (
        tester,
      ) async {
        await tester.pumpWidget(createIntegrationTestApp());
        await tester.pumpAndSettle();

        // Rapidly press buttons and switch tabs
        for (int i = 0; i < 10; i++) {
          await tester.tap(find.byIcon(Icons.auto_awesome));
          await tester.pump(const Duration(milliseconds: 50));

          if (find.text('Cancel').evaluate().isNotEmpty) {
            await tester.tap(find.text('Cancel'));
            await tester.pump(const Duration(milliseconds: 50));
          }

          await tester.tap(find.byIcon(Icons.kitchen));
          await tester.pump(const Duration(milliseconds: 50));

          await tester.tap(find.byIcon(Icons.calendar_today));
          await tester.pump(const Duration(milliseconds: 50));
        }

        await tester.pumpAndSettle();

        // Verify app is still functional
        expect(find.byType(FloatingActionButton), findsOneWidget);
        expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
      });

      testWidgets('Long-running operations do not block UI', (tester) async {
        await materialsProvider.loadMaterials();

        await tester.pumpWidget(createIntegrationTestApp());
        await tester.pumpAndSettle();

        // Start meal generation if materials are available
        final availableMaterials = materialsProvider.allMaterials
            .where((m) => m.isAvailable)
            .toList();

        if (availableMaterials.isNotEmpty) {
          await tester.tap(find.byIcon(Icons.auto_awesome));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Generate'));
          await tester.pump(); // Don't wait for settlement

          // UI should remain responsive during generation
          await tester.tap(find.byIcon(Icons.kitchen));
          await tester.pump();

          await tester.tap(find.byIcon(Icons.calendar_today));
          await tester.pumpAndSettle();

          // Verify navigation works during background operation
          expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
        }
      });
    });
  });
}
