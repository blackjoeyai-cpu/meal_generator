// Accessibility compliance tests for button components
// Tests WCAG 2.1 AA compliance for all interactive elements

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';

import 'package:meal_generator/screens/main_screen.dart';
import 'package:meal_generator/providers/providers.dart';

import '../widgets/button_state_test.mocks.dart';

void main() {
  group('Button Accessibility Compliance Tests', () {
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
    });

    Widget createTestWidget({Widget? child, bool enableSemantics = true}) {
      final app = MultiProvider(
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

      return enableSemantics ? Semantics(child: app) : app;
    }

    group('Screen Reader Support', () {
      testWidgets('All buttons have proper semantic labels', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Test FloatingActionButton semantic properties
        final fabFinder = find.byType(FloatingActionButton);
        expect(fabFinder, findsOneWidget);

        final fab = tester.widget<FloatingActionButton>(fabFinder);
        expect(fab.tooltip, isNotNull);
        expect(fab.tooltip, isNotEmpty);
        expect(fab.tooltip, equals('Generate Meal Plan'));

        // Test that FAB has proper semantics
        final fabSemanticsData = tester.getSemantics(fabFinder);
        expect(fabSemanticsData.label, isNotNull);

        // Test AppBar action buttons
        final refreshButtonFinder = find.byIcon(Icons.refresh);
        expect(refreshButtonFinder, findsOneWidget);

        final refreshButton = tester.widget<IconButton>(refreshButtonFinder);
        expect(refreshButton.tooltip, equals('Refresh'));

        // Test popup menu button
        final menuButtonFinder = find.byIcon(Icons.more_vert);
        expect(menuButtonFinder, findsOneWidget);
      });

      testWidgets('Button states are announced to screen readers', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Test that FAB exists and has semantics
        final fabSemanticsData = tester.getSemantics(
          find.byType(FloatingActionButton),
        );
        expect(fabSemanticsData.label, isNotNull);

        // Test loading state
        when(mockAppProvider.isLoading).thenReturn(true);
        await tester.binding.reassembleApplication();
        await tester.pumpAndSettle();

        // During loading, FAB should not be present
        expect(find.byType(FloatingActionButton), findsNothing);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('Dialog buttons have proper accessibility labels', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Open meal plan generation dialog
        await tester.tap(find.byIcon(Icons.auto_awesome));
        await tester.pumpAndSettle();

        // Test dialog title accessibility
        final dialogTitleSemanticsData = tester.getSemantics(
          find.text('Generate Meal Plan'),
        );
        expect(dialogTitleSemanticsData.label, equals('Generate Meal Plan'));

        // Test dialog button accessibility
        final cancelButtonSemanticsData = tester.getSemantics(
          find.text('Cancel'),
        );
        expect(cancelButtonSemanticsData.label, equals('Cancel'));

        final generateButtonSemanticsData = tester.getSemantics(
          find.text('Generate'),
        );
        expect(generateButtonSemanticsData.label, equals('Generate'));
      });
    });

    group('Touch Target Size Compliance', () {
      testWidgets('All buttons meet minimum 48dp touch target size', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Test FloatingActionButton size
        final fabSize = tester.getSize(find.byType(FloatingActionButton));
        expect(fabSize.width, greaterThanOrEqualTo(48.0));
        expect(fabSize.height, greaterThanOrEqualTo(48.0));

        // Test IconButton sizes in AppBar
        final refreshButtonSize = tester.getSize(find.byIcon(Icons.refresh));
        expect(refreshButtonSize.width, greaterThanOrEqualTo(48.0));
        expect(refreshButtonSize.height, greaterThanOrEqualTo(48.0));

        final menuButtonSize = tester.getSize(find.byIcon(Icons.more_vert));
        expect(menuButtonSize.width, greaterThanOrEqualTo(48.0));
        expect(menuButtonSize.height, greaterThanOrEqualTo(48.0));
      });
    });

    group('Basic Accessibility Tests', () {
      testWidgets('Interactive elements are properly accessible', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Test FAB accessibility
        final fabSemanticsData = tester.getSemantics(
          find.byType(FloatingActionButton),
        );
        expect(fabSemanticsData.label, isNotNull);

        // Test action buttons accessibility
        final refreshSemanticsData = tester.getSemantics(
          find.byIcon(Icons.refresh),
        );
        expect(refreshSemanticsData.label, isNotNull);

        final menuSemanticsData = tester.getSemantics(
          find.byIcon(Icons.more_vert),
        );
        expect(menuSemanticsData.label, isNotNull);
      });

      testWidgets('App navigation is accessible', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Navigate through all tabs and verify accessibility
        final tabIcons = [
          Icons.calendar_today,
          Icons.kitchen,
          Icons.restaurant,
        ];

        for (final icon in tabIcons) {
          await tester.tap(find.byIcon(icon));
          await tester.pumpAndSettle();

          // Verify FAB accessibility in each context
          final fabSemanticsData = tester.getSemantics(
            find.byType(FloatingActionButton),
          );
          expect(fabSemanticsData.label, isNotNull);
          expect(fabSemanticsData.label, isNotEmpty);
        }
      });
    });
  });
}
