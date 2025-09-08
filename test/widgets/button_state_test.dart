// Unit tests for button state management and validation
// Tests button visibility, state changes, and validation logic

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:meal_generator/screens/main_screen.dart';
import 'package:meal_generator/providers/providers.dart';
import 'package:meal_generator/models/models.dart' as meal_models;

import 'button_state_test.mocks.dart';

@GenerateMocks([AppProvider, MaterialsProvider, MealPlansProvider])
void main() {
  group('Button State Management Tests', () {
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
      when(mockMealPlansProvider.selectedDate).thenReturn(DateTime.now());
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

    testWidgets('FloatingActionButton changes based on selected tab', (
      tester,
    ) async {
      // Given: App is initialized with providers
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Then: Should show Calendar tab FAB initially (index 0)
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
      expect(find.byTooltip('Generate Meal Plan'), findsOneWidget);

      // When: User switches to Materials tab (index 1)
      await tester.tap(find.byIcon(Icons.kitchen));
      await tester.pumpAndSettle();

      // Then: FAB should change to Materials tab configuration
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byTooltip('Add Material'), findsOneWidget);

      // When: User switches to Meal Plans tab (index 2)
      await tester.tap(find.byIcon(Icons.restaurant));
      await tester.pumpAndSettle();

      // Then: FAB should change to Meal Plans tab configuration
      expect(find.byIcon(Icons.view_week), findsOneWidget);
      expect(find.byTooltip('Generate Weekly Plan'), findsOneWidget);

      // When: User switches back to Calendar tab
      await tester.tap(find.byIcon(Icons.calendar_today));
      await tester.pumpAndSettle();

      // Then: FAB should return to Calendar configuration
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
      expect(find.byTooltip('Generate Meal Plan'), findsOneWidget);
    });

    testWidgets('Generate buttons validate material availability', (
      tester,
    ) async {
      // Given: App with empty materials list
      when(mockMaterialsProvider.allMaterials).thenReturn([]);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // When: User attempts to generate meal plan with no materials
      await tester.tap(find.byIcon(Icons.auto_awesome));
      await tester.pumpAndSettle();

      // Then: Dialog should appear
      expect(find.text('Generate Meal Plan'), findsOneWidget);

      // When: User confirms generation
      await tester.tap(find.text('Generate'));
      await tester.pumpAndSettle();

      // Then: Error message should be displayed
      expect(
        find.text(
          'No available materials found. Please add some materials first.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('Generate buttons work with available materials', (
      tester,
    ) async {
      // Given: App with available materials
      final availableMaterial = meal_models.Material(
        id: 'test-1',
        name: 'Test Material',
        category: meal_models.MaterialCategory.vegetables,
        isAvailable: true,
      );

      when(mockMaterialsProvider.allMaterials).thenReturn([availableMaterial]);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // When: User attempts to generate meal plan with available materials
      await tester.tap(find.byIcon(Icons.auto_awesome));
      await tester.pumpAndSettle();

      // Then: Dialog should appear
      expect(find.text('Generate Meal Plan'), findsOneWidget);

      // When: User confirms generation
      await tester.tap(find.text('Generate'));
      await tester.pumpAndSettle();

      // Then: Generation method should be called
      verify(
        mockMealPlansProvider.generateMealPlan([availableMaterial]),
      ).called(1);
    });

    testWidgets('Weekly plan generation validates materials', (tester) async {
      // Given: App with no available materials
      when(mockMaterialsProvider.allMaterials).thenReturn([
        meal_models.Material(
          id: 'test-1',
          name: 'Test Material',
          category: meal_models.MaterialCategory.vegetables,
          isAvailable: false, // Not available
        ),
      ]);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // When: User switches to Meal Plans tab
      await tester.tap(find.byIcon(Icons.restaurant));
      await tester.pumpAndSettle();

      // When: User attempts to generate weekly plan
      await tester.tap(find.byIcon(Icons.view_week));
      await tester.pumpAndSettle();

      // Then: Dialog should appear
      expect(find.text('Generate Weekly Plan'), findsOneWidget);

      // When: User confirms generation
      await tester.tap(find.text('Generate'));
      await tester.pumpAndSettle();

      // Then: Error message should be displayed
      expect(
        find.text(
          'No available materials found. Please add some materials first.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('Refresh button triggers data reload', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // When: User taps refresh button
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      // Then: Both providers should reload data
      verify(mockMaterialsProvider.loadMaterials()).called(1);
      verify(mockMealPlansProvider.loadCurrentMonthMealPlans()).called(1);
    });

    testWidgets('Settings menu button shows settings dialog', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // When: User taps settings menu button
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Then: Settings dialog should appear
      expect(find.text('Settings'), findsNWidgets(2)); // Title and menu item
      expect(find.text('Settings functionality coming soon!'), findsOneWidget);
    });

    testWidgets('About menu button shows about dialog', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // When: User taps about menu button
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('About'));
      await tester.pumpAndSettle();

      // Then: About dialog should appear
      expect(
        find.text('Meal Planner'),
        findsNWidgets(2),
      ); // App bar and dialog title
      expect(find.text('1.0.0'), findsOneWidget);
    });

    testWidgets('Dialog cancel buttons close dialogs without action', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // When: User opens meal plan generation dialog
      await tester.tap(find.byIcon(Icons.auto_awesome));
      await tester.pumpAndSettle();

      expect(find.text('Generate Meal Plan'), findsOneWidget);

      // When: User taps Cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Then: Dialog should be closed
      expect(find.text('Generate Meal Plan'), findsNothing);

      // And: No generation should be triggered
      verifyNever(mockMealPlansProvider.generateMealPlan(any));
    });

    testWidgets('Loading state disables buttons appropriately', (tester) async {
      // Given: App in loading state
      when(mockAppProvider.isLoading).thenReturn(true);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Then: Should show loading indicator instead of content
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // And: FAB should not be visible during loading
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('Error state shows retry functionality', (tester) async {
      // Given: App with error state
      when(mockAppProvider.errorMessage).thenReturn('Test error message');

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Then: Should show error UI
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Test error message'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      // When: User taps Try Again
      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();

      // Then: Should clear error and reload data
      verify(mockAppProvider.clearError()).called(1);
    });

    group('Tab-specific button behavior', () {
      testWidgets('Calendar tab FAB shows appropriate tooltip', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Should be on Calendar tab by default
        final fabFinder = find.byType(FloatingActionButton);
        expect(fabFinder, findsOneWidget);

        final fab = tester.widget<FloatingActionButton>(fabFinder);
        expect(fab.tooltip, equals('Generate Meal Plan'));
        expect(fab.child, isA<Icon>());
        expect((fab.child as Icon).icon, equals(Icons.auto_awesome));
      });

      testWidgets('Materials tab FAB shows appropriate tooltip', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Switch to Materials tab
        await tester.tap(find.byIcon(Icons.kitchen));
        await tester.pumpAndSettle();

        final fabFinder = find.byType(FloatingActionButton);
        expect(fabFinder, findsOneWidget);

        final fab = tester.widget<FloatingActionButton>(fabFinder);
        expect(fab.tooltip, equals('Add Material'));
        expect(fab.child, isA<Icon>());
        expect((fab.child as Icon).icon, equals(Icons.add));
      });

      testWidgets('Meal Plans tab FAB shows appropriate tooltip', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Switch to Meal Plans tab
        await tester.tap(find.byIcon(Icons.restaurant));
        await tester.pumpAndSettle();

        final fabFinder = find.byType(FloatingActionButton);
        expect(fabFinder, findsOneWidget);

        final fab = tester.widget<FloatingActionButton>(fabFinder);
        expect(fab.tooltip, equals('Generate Weekly Plan'));
        expect(fab.child, isA<Icon>());
        expect((fab.child as Icon).icon, equals(Icons.view_week));
      });
    });

    group('Provider state validation', () {
      testWidgets('Buttons respect provider loading states', (tester) async {
        // Given: MaterialsProvider is loading
        when(mockMaterialsProvider.isLoading).thenReturn(true);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Then: Should show loading indicator
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsNothing);
      });

      testWidgets('Buttons handle provider error states', (tester) async {
        // Given: MealPlansProvider has error
        when(mockMealPlansProvider.isLoading).thenReturn(false);
        when(mockMealPlansProvider.errorMessage).thenReturn('Meal plans error');

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Then: Should show error state
        expect(find.text('Something went wrong'), findsOneWidget);
        expect(find.text('Meal plans error'), findsOneWidget);
      });
    });
  });
}
