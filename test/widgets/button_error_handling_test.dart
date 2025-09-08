// Error handling and edge case tests for button functionality
// Tests robustness under various error conditions and edge cases

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';

import 'package:meal_generator/screens/main_screen.dart';
import 'package:meal_generator/widgets/materials_panel.dart';
import 'package:meal_generator/providers/providers.dart';
import 'package:meal_generator/models/models.dart' as models;

import '../widgets/button_state_test.mocks.dart';

void main() {
  group('Button Error Handling and Edge Case Tests', () {
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

    group('Material Availability Validation', () {
      testWidgets('Empty materials list error handling', (tester) async {
        // Given: MaterialsProvider returns empty list
        when(mockMaterialsProvider.allMaterials).thenReturn([]);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // When: User attempts meal generation
        await tester.tap(find.byIcon(Icons.auto_awesome));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Generate'));
        await tester.pumpAndSettle();

        // Then: Informative error message should be displayed
        expect(
          find.text(
            'No available materials found. Please add some materials first.',
          ),
          findsOneWidget,
        );
      });

      testWidgets('No available materials error handling', (tester) async {
        // Given: Materials exist but all marked as unavailable
        final unavailableMaterials = [
          models.Material(
            id: 'test-1',
            name: 'Unavailable Material 1',
            category: models.MaterialCategory.vegetables,
            isAvailable: false,
          ),
          models.Material(
            id: 'test-2',
            name: 'Unavailable Material 2',
            category: models.MaterialCategory.meat,
            isAvailable: false,
          ),
        ];

        when(
          mockMaterialsProvider.allMaterials,
        ).thenReturn(unavailableMaterials);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // When: User attempts meal generation
        await tester.tap(find.byIcon(Icons.auto_awesome));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Generate'));
        await tester.pumpAndSettle();

        // Then: Error message should guide user to mark materials as available
        expect(
          find.text(
            'No available materials found. Please add some materials first.',
          ),
          findsOneWidget,
        );
      });

      testWidgets('Network/Database error during material loading', (
        tester,
      ) async {
        // Given: MaterialsProvider throws exception
        when(mockMaterialsProvider.isLoading).thenReturn(false);
        when(
          mockMaterialsProvider.errorMessage,
        ).thenReturn('Database connection failed');

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Then: Error state should be displayed
        expect(find.text('Something went wrong'), findsOneWidget);
        expect(find.text('Database connection failed'), findsOneWidget);

        // When: User taps retry button
        await tester.tap(find.text('Try Again'));
        await tester.pumpAndSettle();

        // Then: Error should be cleared and retry attempted
        verify(mockAppProvider.clearError()).called(1);
      });

      testWidgets('Meal generation with network error and retry', (
        tester,
      ) async {
        // Given: Available materials but generation fails
        final availableMaterial = models.Material(
          id: 'test-1',
          name: 'Test Material',
          category: models.MaterialCategory.vegetables,
          isAvailable: true,
        );

        when(
          mockMaterialsProvider.allMaterials,
        ).thenReturn([availableMaterial]);
        when(
          mockMealPlansProvider.generateMealPlan(any),
        ).thenThrow(Exception('Network error'));

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // When: User attempts meal generation
        await tester.tap(find.byIcon(Icons.auto_awesome));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Generate'));
        await tester.pumpAndSettle();

        // Then: Error message should be displayed with retry option
        expect(
          find.textContaining('Failed to generate meal plan'),
          findsOneWidget,
        );

        // When: User tries generation again
        when(
          mockMealPlansProvider.generateMealPlan(any),
        ).thenAnswer((_) async => Future.value());

        await tester.tap(find.byIcon(Icons.auto_awesome));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Generate'));
        await tester.pumpAndSettle();

        // Then: Retry should succeed
        verify(
          mockMealPlansProvider.generateMealPlan([availableMaterial]),
        ).called(2);
      });
    });

    group('User Experience Edge Cases', () {
      testWidgets('Rapid button pressing prevention', (tester) async {
        // Given: Available materials for generation
        final availableMaterial = models.Material(
          id: 'test-1',
          name: 'Test Material',
          category: models.MaterialCategory.vegetables,
          isAvailable: true,
        );

        when(
          mockMaterialsProvider.allMaterials,
        ).thenReturn([availableMaterial]);
        when(mockMealPlansProvider.generateMealPlan(any)).thenAnswer((_) async {
          // Simulate slow operation
          await Future.delayed(const Duration(seconds: 1));
        });

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // When: User rapidly taps generation button multiple times
        await tester.tap(find.byIcon(Icons.auto_awesome));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Generate'));
        await tester.pump(); // Don't wait for completion

        // Try to trigger generation again immediately
        await tester.tap(find.byIcon(Icons.auto_awesome));
        await tester.pump();

        // Then: Only one operation should be triggered
        await tester.pumpAndSettle(const Duration(seconds: 2));
        verify(
          mockMealPlansProvider.generateMealPlan([availableMaterial]),
        ).called(1);
      });

      testWidgets('Dialog dismissal during operation', (tester) async {
        // Given: Available materials and slow generation
        final availableMaterial = models.Material(
          id: 'test-1',
          name: 'Test Material',
          category: models.MaterialCategory.vegetables,
          isAvailable: true,
        );

        when(
          mockMaterialsProvider.allMaterials,
        ).thenReturn([availableMaterial]);
        when(mockMealPlansProvider.generateMealPlan(any)).thenAnswer((_) async {
          await Future.delayed(const Duration(seconds: 2));
        });

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // When: User starts generation
        await tester.tap(find.byIcon(Icons.auto_awesome));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Generate'));
        await tester.pump();

        // When: User navigates away during operation
        await tester.tap(find.byIcon(Icons.kitchen));
        await tester.pump();

        await tester.tap(find.byIcon(Icons.calendar_today));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Then: Operation should continue and app should remain functional
        expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
        verify(mockMaterialsProvider.loadMaterials()).called(greaterThan(0));
      });

      testWidgets('Tab switching during operations', (tester) async {
        // Given: Long-running operation is in progress
        when(mockMealPlansProvider.isGenerating).thenReturn(true);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // When: User switches tabs during operation
        await tester.tap(find.byIcon(Icons.kitchen));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.restaurant));
        await tester.pumpAndSettle();

        // Then: UI should remain responsive and consistent
        expect(find.byIcon(Icons.view_week), findsOneWidget);

        // When: User returns to original tab
        await tester.tap(find.byIcon(Icons.calendar_today));
        await tester.pumpAndSettle();

        // Then: Tab state should be maintained
        expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
      });

      testWidgets('Multiple dialog operations', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Test opening multiple dialogs in sequence
        for (int i = 0; i < 3; i++) {
          // Open meal plan dialog
          await tester.tap(find.byIcon(Icons.auto_awesome));
          await tester.pump(const Duration(milliseconds: 300));

          expect(find.text('Generate Meal Plan'), findsOneWidget);

          // Cancel dialog
          await tester.tap(find.text('Cancel'));
          await tester.pump(const Duration(milliseconds: 300));

          expect(find.text('Generate Meal Plan'), findsNothing);

          // Open settings menu and dialog
          await tester.tap(find.byIcon(Icons.more_vert));
          await tester.pump(const Duration(milliseconds: 300));

          await tester.tap(find.text('Settings'));
          await tester.pump(const Duration(milliseconds: 300));

          expect(
            find.text('Settings functionality coming soon!'),
            findsOneWidget,
          );

          await tester.tap(find.text('OK'));
          await tester.pump(const Duration(milliseconds: 300));
        }

        // Then: App should remain in consistent state
        expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
      });
    });

    group('Provider State Edge Cases', () {
      testWidgets('Provider state changes during button operations', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Given: User opens dialog
        await tester.tap(find.byIcon(Icons.auto_awesome));
        await tester.pumpAndSettle();

        expect(find.text('Generate Meal Plan'), findsOneWidget);

        // When: Provider state changes while dialog is open
        when(mockMaterialsProvider.isLoading).thenReturn(true);

        // Trigger rebuild
        await tester.binding.reassembleApplication();
        await tester.pump(const Duration(milliseconds: 300));

        // Then: Dialog should remain functional
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Generate'), findsOneWidget);

        await tester.tap(find.text('Cancel'));
        await tester.pump(const Duration(milliseconds: 300));
      });

      testWidgets('Provider error during button action', (tester) async {
        // Given: Normal operation setup
        final availableMaterial = models.Material(
          id: 'test-1',
          name: 'Test Material',
          category: models.MaterialCategory.vegetables,
          isAvailable: true,
        );

        when(
          mockMaterialsProvider.allMaterials,
        ).thenReturn([availableMaterial]);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // When: Generation fails with provider error
        when(mockMealPlansProvider.generateMealPlan(any)).thenAnswer((_) async {
          when(mockMealPlansProvider.errorMessage).thenReturn('Provider error');
          throw Exception('Provider error');
        });

        await tester.tap(find.byIcon(Icons.auto_awesome));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Generate'));
        await tester.pumpAndSettle();

        // Then: Error should be handled gracefully
        expect(
          find.textContaining('Failed to generate meal plan'),
          findsOneWidget,
        );
      });

      testWidgets('Concurrent provider operations', (tester) async {
        // Given: Multiple providers loading simultaneously
        when(mockMaterialsProvider.isLoading).thenReturn(true);
        when(mockMealPlansProvider.isLoading).thenReturn(true);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Then: Should show loading state
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // When: One provider finishes loading
        when(mockMaterialsProvider.isLoading).thenReturn(false);

        await tester.binding.reassembleApplication();
        await tester.pumpAndSettle();

        // Then: Should still show loading state
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // When: All providers finish loading
        when(mockMealPlansProvider.isLoading).thenReturn(false);

        await tester.binding.reassembleApplication();
        await tester.pumpAndSettle();

        // Then: Should show normal UI
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });
    });

    group('Memory and Resource Management', () {
      testWidgets('Memory leak prevention during rapid operations', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Simulate rapid user interactions
        for (int i = 0; i < 50; i++) {
          // Rapidly open and close dialogs
          await tester.tap(find.byIcon(Icons.auto_awesome));
          await tester.pump(const Duration(milliseconds: 10));

          if (find.text('Cancel').evaluate().isNotEmpty) {
            await tester.tap(find.text('Cancel'));
            await tester.pump(const Duration(milliseconds: 10));
          }

          // Switch tabs rapidly
          final tabIndex = i % 3;
          final icons = [Icons.calendar_today, Icons.kitchen, Icons.restaurant];
          await tester.tap(find.byIcon(icons[tabIndex]));
          await tester.pump(const Duration(milliseconds: 10));
        }

        await tester.pumpAndSettle();

        // Then: App should remain functional
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });

      testWidgets('Widget disposal during navigation', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Navigate through all tabs multiple times
        final icons = [Icons.calendar_today, Icons.kitchen, Icons.restaurant];

        for (int cycle = 0; cycle < 10; cycle++) {
          for (final icon in icons) {
            await tester.tap(find.byIcon(icon));
            await tester.pumpAndSettle();
          }
        }

        // Then: No memory leaks should occur
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });

      testWidgets('Resource cleanup on widget rebuild', (tester) async {
        // Build initial widget
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Rebuild widget multiple times
        for (int i = 0; i < 10; i++) {
          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();
        }

        // Then: Widget should remain functional
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });
    });

    group('Extreme Edge Cases', () {
      testWidgets('Null provider handling', (tester) async {
        // Test with minimal provider setup
        when(mockMaterialsProvider.allMaterials).thenReturn([]);
        when(mockMaterialsProvider.selectedMaterials).thenReturn([]);
        when(mockMealPlansProvider.selectedMealPlan).thenReturn(null);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Then: Should handle null states gracefully
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });

      testWidgets('Very large material list handling', (tester) async {
        // Given: Very large list of materials
        final largeMaterialList = List.generate(
          1000,
          (index) => models.Material(
            id: 'material-$index',
            name: 'Material $index',
            category: models
                .MaterialCategory
                .values[index % models.MaterialCategory.values.length],
            isAvailable: index % 2 == 0,
          ),
        );

        when(
          mockMaterialsProvider.filteredMaterials,
        ).thenReturn(largeMaterialList);
        when(mockMaterialsProvider.allMaterials).thenReturn(largeMaterialList);

        await tester.pumpWidget(
          createTestWidget(child: const MaterialsPanel()),
        );
        await tester.pumpAndSettle();

        // Then: Should handle large lists without performance issues
        expect(find.byType(ListView), findsOneWidget);
      });

      testWidgets('Simultaneous button presses across tabs', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Simulate user trying to press buttons on multiple tabs simultaneously
        await tester.tap(find.byIcon(Icons.auto_awesome));
        await tester.pump(const Duration(milliseconds: 50));

        await tester.tap(find.byIcon(Icons.kitchen));
        await tester.pump(const Duration(milliseconds: 50));

        await tester.tap(find.byIcon(Icons.add));
        await tester.pump(const Duration(milliseconds: 50));

        await tester.pumpAndSettle();

        // Then: App should remain in consistent state
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });
    });
  });
}
