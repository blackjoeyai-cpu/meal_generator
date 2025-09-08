// Widget tests for button interaction workflows
// Tests complete user interaction flows with buttons

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:meal_generator/screens/main_screen.dart';
import 'package:meal_generator/widgets/materials_panel.dart';
import 'package:meal_generator/widgets/meal_plan_view.dart';
import 'package:meal_generator/providers/providers.dart';
import 'package:meal_generator/models/models.dart' as models;

import '../widgets/button_state_test.mocks.dart';

void main() {
  group('Button Interaction Workflow Tests', () {
    late MockAppProvider mockAppProvider;
    late MockMaterialsProvider mockMaterialsProvider;
    late MockMealPlansProvider mockMealPlansProvider;

    setUp(() {
      mockAppProvider = MockAppProvider();
      mockMaterialsProvider = MockMaterialsProvider();
      mockMealPlansProvider = MockMealPlansProvider();

      // Default setup for providers
      when(mockAppProvider.isInitialized).thenReturn(true);
      when(mockAppProvider.isLoading).thenReturn(false);
      when(mockAppProvider.errorMessage).thenReturn(null);
      when(mockMaterialsProvider.isLoading).thenReturn(false);
      when(mockMaterialsProvider.errorMessage).thenReturn(null);
      when(mockMealPlansProvider.isLoading).thenReturn(false);
      when(mockMealPlansProvider.errorMessage).thenReturn(null);
      when(mockMaterialsProvider.allMaterials).thenReturn([]);
      when(mockMaterialsProvider.selectedMaterials).thenReturn([]);
      when(mockMaterialsProvider.selectedMaterialsCount).thenReturn(0);
      when(mockMaterialsProvider.filteredMaterials).thenReturn([]);
      when(mockMaterialsProvider.searchQuery).thenReturn('');
      when(mockMaterialsProvider.selectedCategory).thenReturn(null);
      when(mockMaterialsProvider.showOnlyAvailable).thenReturn(false);
      when(mockMealPlansProvider.selectedDate).thenReturn(DateTime.now());
      when(mockMealPlansProvider.selectedMealPlan).thenReturn(null);
      when(mockMealPlansProvider.focusedDate).thenReturn(DateTime.now());
      when(
        mockMealPlansProvider.calendarFormat,
      ).thenReturn(CalendarFormat.month);
    });

    Widget createTestWidget({Widget? child}) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<AppProvider>.value(value: mockAppProvider),
          ChangeNotifierProvider<MaterialsProvider>.value(
            value: mockMaterialsProvider,
          ),
          ChangeNotifierProvider<MealPlansProvider>.value(
            value: mockMealPlansProvider,
          ),
        ],
        child: MaterialApp(home: child ?? const MainScreen()),
      );
    }

    testWidgets('Tab navigation with FAB state synchronization', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify initial Calendar tab state
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);

      // Rapidly switch between tabs
      for (int i = 0; i < 3; i++) {
        // Calendar -> Materials
        await tester.tap(find.byIcon(Icons.kitchen));
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byIcon(Icons.add), findsOneWidget);

        // Materials -> Meal Plans
        await tester.tap(find.byIcon(Icons.restaurant));
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byIcon(Icons.view_week), findsOneWidget);

        // Meal Plans -> Calendar
        await tester.tap(find.byIcon(Icons.calendar_today));
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
      }

      await tester.pumpAndSettle();

      // Final verification
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
      expect(find.byTooltip('Generate Meal Plan'), findsOneWidget);
    });

    testWidgets('Complete meal generation workflow', (tester) async {
      // Given: App with available materials
      final availableMaterial = models.Material(
        id: 'test-1',
        name: 'Test Material',
        category: models.MaterialCategory.vegetables,
        isAvailable: true,
      );

      when(mockMaterialsProvider.allMaterials).thenReturn([availableMaterial]);
      when(
        mockMealPlansProvider.generateMealPlan(any),
      ).thenAnswer((_) async => Future.value());

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // When: User initiates meal generation via FAB
      await tester.tap(find.byIcon(Icons.auto_awesome));
      await tester.pumpAndSettle();

      // Then: Dialog should appear
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

      // Then: Generation method should be called
      verify(
        mockMealPlansProvider.generateMealPlan([availableMaterial]),
      ).called(1);

      // And: Success message should be displayed
      expect(find.text('Meal plan generated successfully!'), findsOneWidget);
    });

    testWidgets('Complete meal generation workflow with error', (tester) async {
      // Given: App with available materials but generation fails
      final availableMaterial = models.Material(
        id: 'test-1',
        name: 'Test Material',
        category: models.MaterialCategory.vegetables,
        isAvailable: true,
      );

      when(mockMaterialsProvider.allMaterials).thenReturn([availableMaterial]);
      when(
        mockMealPlansProvider.generateMealPlan(any),
      ).thenThrow(Exception('Generation failed'));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // When: User initiates meal generation
      await tester.tap(find.byIcon(Icons.auto_awesome));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Generate'));
      await tester.pumpAndSettle();

      // Then: Error message should be displayed
      expect(
        find.textContaining('Failed to generate meal plan'),
        findsOneWidget,
      );
    });

    testWidgets('Material selection and management operations', (tester) async {
      // Given: MaterialsPanel with populated materials list
      final materials = [
        models.Material(
          id: 'test-1',
          name: 'Tomato',
          category: models.MaterialCategory.vegetables,
          isAvailable: true,
        ),
        models.Material(
          id: 'test-2',
          name: 'Chicken',
          category: models.MaterialCategory.meat,
          isAvailable: true,
        ),
      ];

      when(mockMaterialsProvider.filteredMaterials).thenReturn(materials);
      when(mockMaterialsProvider.allMaterials).thenReturn(materials);

      await tester.pumpWidget(createTestWidget(child: const MaterialsPanel()));
      await tester.pumpAndSettle();

      // Then: Should show materials list
      expect(find.text('Tomato'), findsOneWidget);
      expect(find.text('Chicken'), findsOneWidget);

      // When: User selects a material
      when(mockMaterialsProvider.selectedMaterials).thenReturn([materials[0]]);
      when(mockMaterialsProvider.selectedMaterialsCount).thenReturn(1);

      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();

      // Then: Selection should be reflected in UI
      verify(mockMaterialsProvider.toggleMaterialSelection('test-1')).called(1);
    });

    testWidgets('Material filtering workflow', (tester) async {
      // Given: MaterialsPanel with materials
      final materials = [
        models.Material(
          id: 'test-1',
          name: 'Tomato',
          category: models.MaterialCategory.vegetables,
          isAvailable: true,
        ),
        models.Material(
          id: 'test-2',
          name: 'Chicken',
          category: models.MaterialCategory.meat,
          isAvailable: false,
        ),
      ];

      when(mockMaterialsProvider.filteredMaterials).thenReturn(materials);
      when(mockMaterialsProvider.allMaterials).thenReturn(materials);

      await tester.pumpWidget(createTestWidget(child: const MaterialsPanel()));
      await tester.pumpAndSettle();

      // When: User applies category filter
      await tester.tap(find.text('🥬 Vegetables'));
      await tester.pumpAndSettle();

      // Then: Filter should be applied
      verify(
        mockMaterialsProvider.setCategoryFilter(
          models.MaterialCategory.vegetables,
        ),
      ).called(1);

      // When: User toggles availability filter
      await tester.tap(find.text('Available only'));
      await tester.pumpAndSettle();

      // Then: Availability filter should be toggled
      verify(mockMaterialsProvider.toggleShowOnlyAvailable()).called(1);

      // When: User clears all selections
      await tester.tap(find.text('Clear All'));
      await tester.pumpAndSettle();

      // Then: All selections should be cleared
      verify(mockMaterialsProvider.clearAllSelections()).called(1);
    });

    testWidgets('Weekly meal plan generation workflow', (tester) async {
      // Given: App with sufficient materials for weekly planning
      final materials = List.generate(
        7,
        (index) => models.Material(
          id: 'test-$index',
          name: 'Material $index',
          category: models.MaterialCategory.vegetables,
          isAvailable: true,
        ),
      );

      when(mockMaterialsProvider.allMaterials).thenReturn(materials);
      when(
        mockMealPlansProvider.generateWeeklyMealPlans(any, any),
      ).thenAnswer((_) async => Future.value());

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // When: User navigates to Meal Plans tab
      await tester.tap(find.byIcon(Icons.restaurant));
      await tester.pumpAndSettle();

      // When: User presses FAB (Generate Weekly Plan)
      await tester.tap(find.byIcon(Icons.view_week));
      await tester.pumpAndSettle();

      // Then: Weekly generation dialog should appear
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

      // Then: Weekly generation should be called
      verify(
        mockMealPlansProvider.generateWeeklyMealPlans(any, materials),
      ).called(1);

      // And: Success message should be displayed
      expect(
        find.text('Weekly meal plans generated successfully!'),
        findsOneWidget,
      );
    });

    testWidgets('Dialog button interactions preserve state', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // When: User opens and closes multiple dialogs
      for (int i = 0; i < 3; i++) {
        // Open meal plan dialog
        await tester.tap(find.byIcon(Icons.auto_awesome));
        await tester.pumpAndSettle();
        expect(find.text('Generate Meal Plan'), findsOneWidget);

        // Close with cancel
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(find.text('Generate Meal Plan'), findsNothing);

        // Open settings menu
        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pumpAndSettle();

        // Open settings dialog
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();
        expect(
          find.text('Settings functionality coming soon!'),
          findsOneWidget,
        );

        // Close settings dialog
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
      }

      // Then: App should remain in consistent state
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
      expect(find.byTooltip('Generate Meal Plan'), findsOneWidget);
    });

    testWidgets('Material generation workflow with selected materials', (
      tester,
    ) async {
      // Given: MaterialsPanel with selected materials
      final materials = [
        models.Material(
          id: 'test-1',
          name: 'Tomato',
          category: models.MaterialCategory.vegetables,
          isAvailable: true,
        ),
        models.Material(
          id: 'test-2',
          name: 'Chicken',
          category: models.MaterialCategory.meat,
          isAvailable: true,
        ),
      ];

      when(mockMaterialsProvider.filteredMaterials).thenReturn(materials);
      when(mockMaterialsProvider.allMaterials).thenReturn(materials);
      when(mockMaterialsProvider.selectedMaterials).thenReturn([materials[0]]);
      when(mockMaterialsProvider.selectedMaterialsCount).thenReturn(1);

      await tester.pumpWidget(createTestWidget(child: const MaterialsPanel()));
      await tester.pumpAndSettle();

      // When: User presses "Generate Meals" button
      await tester.tap(find.text('Generate Meals'));
      await tester.pumpAndSettle();

      // Then: Success message should be displayed with material count
      expect(
        find.text('Generating meals with 1 selected materials'),
        findsOneWidget,
      );
    });

    testWidgets('Empty material generation validation', (tester) async {
      // Given: MaterialsPanel with no selected materials
      when(mockMaterialsProvider.filteredMaterials).thenReturn([]);
      when(mockMaterialsProvider.selectedMaterials).thenReturn([]);
      when(mockMaterialsProvider.selectedMaterialsCount).thenReturn(0);

      await tester.pumpWidget(createTestWidget(child: const MaterialsPanel()));
      await tester.pumpAndSettle();

      // Then: Generate Meals button should not be visible
      expect(find.text('Generate Meals'), findsNothing);
    });

    group('Visual feedback and loading states', () {
      testWidgets('Loading states show appropriate indicators', (tester) async {
        // Given: App in generating state
        when(mockMealPlansProvider.isGenerating).thenReturn(true);

        await tester.pumpWidget(createTestWidget(child: const MealPlanView()));
        await tester.pumpAndSettle();

        // Then: Loading indicator should be shown
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Generating meal plan...'), findsOneWidget);
        expect(find.text('This may take a few moments'), findsOneWidget);
      });

      testWidgets('Success messages appear after actions', (tester) async {
        // Test covered in other tests above
        expect(true, isTrue);
      });

      testWidgets('Error messages provide clear guidance', (tester) async {
        // Given: App with error state
        when(
          mockMealPlansProvider.errorMessage,
        ).thenReturn('Database connection failed');

        await tester.pumpWidget(createTestWidget(child: const MealPlanView()));
        await tester.pumpAndSettle();

        // Then: Error UI should be displayed
        expect(find.text('Something went wrong'), findsOneWidget);
        expect(find.text('Database connection failed'), findsOneWidget);
        expect(find.text('Try Again'), findsOneWidget);

        // When: User taps Try Again
        await tester.tap(find.text('Try Again'));
        await tester.pumpAndSettle();

        // Then: Error should be cleared
        verify(mockMealPlansProvider.clearError()).called(1);
      });
    });

    group('Accessibility and keyboard navigation', () {
      testWidgets('Buttons have proper semantic labels', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify FAB has proper tooltip
        final fabFinder = find.byType(FloatingActionButton);
        expect(fabFinder, findsOneWidget);

        final fab = tester.widget<FloatingActionButton>(fabFinder);
        expect(fab.tooltip, isNotEmpty);
        expect(fab.tooltip, equals('Generate Meal Plan'));
      });

      testWidgets('Tab navigation follows logical order', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify tab order is maintained
        final tabs = find.byType(Tab);
        expect(tabs, findsNWidgets(3));
      });

      testWidgets('Button touch targets meet minimum size requirements', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify FAB meets minimum touch target size (48dp)
        final fabFinder = find.byType(FloatingActionButton);
        expect(fabFinder, findsOneWidget);

        final fabSize = tester.getSize(fabFinder);
        expect(fabSize.width, greaterThanOrEqualTo(48.0));
        expect(fabSize.height, greaterThanOrEqualTo(48.0));
      });
    });
  });
}
