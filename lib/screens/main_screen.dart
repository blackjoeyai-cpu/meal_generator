// Main screen of the meal planner application
// Contains the primary navigation and layout structure

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../utils/utils.dart';
import '../widgets/calendar_view.dart';
import '../widgets/materials_panel.dart';
import '../widgets/meal_plan_view.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final materialsProvider = context.read<MaterialsProvider>();
    final mealPlansProvider = context.read<MealPlansProvider>();

    // Load materials and current month meal plans
    await Future.wait([
      materialsProvider.loadMaterials(),
      mealPlansProvider.loadCurrentMonthMealPlans(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Planner'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInitialData,
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuSelection,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'about',
                child: ListTile(
                  leading: Icon(Icons.info),
                  title: Text('About'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          tabs: const [
            Tab(icon: Icon(Icons.calendar_today), text: 'Calendar'),
            Tab(icon: Icon(Icons.kitchen), text: 'Materials'),
            Tab(icon: Icon(Icons.restaurant), text: 'Meal Plans'),
          ],
        ),
      ),
      body: Consumer3<AppProvider, MaterialsProvider, MealPlansProvider>(
        builder:
            (
              context,
              appProvider,
              materialsProvider,
              mealPlansProvider,
              child,
            ) {
              if (appProvider.isLoading ||
                  materialsProvider.isLoading ||
                  mealPlansProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (appProvider.errorMessage != null) {
                return _buildErrorWidget(appProvider.errorMessage!, () {
                  appProvider.clearError();
                  _loadInitialData();
                });
              }

              return TabBarView(
                controller: _tabController,
                children: const [
                  CalendarView(),
                  MaterialsPanel(),
                  MealPlanView(),
                ],
              );
            },
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildErrorWidget(String error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Something went wrong',
              style: AppTypography.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              error,
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(onPressed: onRetry, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    switch (_currentIndex) {
      case 0: // Calendar tab
        return FloatingActionButton(
          onPressed: _showGenerateMealPlanDialog,
          tooltip: 'Generate Meal Plan',
          child: const Icon(Icons.auto_awesome),
        );
      case 1: // Materials tab
        return FloatingActionButton(
          onPressed: _showAddMaterialDialog,
          tooltip: 'Add Material',
          child: const Icon(Icons.add),
        );
      case 2: // Meal Plans tab
        return FloatingActionButton(
          onPressed: _showGenerateWeeklyPlanDialog,
          tooltip: 'Generate Weekly Plan',
          child: const Icon(Icons.view_week),
        );
      default:
        return null;
    }
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'settings':
        _showSettingsDialog();
        break;
      case 'about':
        _showAboutDialog();
        break;
    }
  }

  void _showGenerateMealPlanDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Meal Plan'),
        content: const Text(
          'Generate a meal plan for the selected date using available materials?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _generateMealPlan();
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  void _showAddMaterialDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add material functionality coming soon!')),
    );
  }

  void _showGenerateWeeklyPlanDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Weekly Plan'),
        content: const Text(
          'Generate meal plans for the entire week starting from the selected date?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _generateWeeklyPlan();
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: const Text('Settings functionality coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Meal Planner',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.restaurant_menu,
        size: 48,
        color: AppColors.primary,
      ),
      children: const [
        Text(
          'A simple and intuitive meal planning application that helps you generate personalized meal plans based on available ingredients.',
        ),
      ],
    );
  }

  Future<void> _generateMealPlan() async {
    final materialsProvider = context.read<MaterialsProvider>();
    final mealPlansProvider = context.read<MealPlansProvider>();

    final availableMaterials = materialsProvider.allMaterials
        .where((material) => material.isAvailable)
        .toList();

    if (availableMaterials.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No available materials found. Please add some materials first.',
          ),
        ),
      );
      return;
    }

    try {
      await mealPlansProvider.generateMealPlan(availableMaterials);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal plan generated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate meal plan: $e')),
        );
      }
    }
  }

  Future<void> _generateWeeklyPlan() async {
    final materialsProvider = context.read<MaterialsProvider>();
    final mealPlansProvider = context.read<MealPlansProvider>();

    final availableMaterials = materialsProvider.allMaterials
        .where((material) => material.isAvailable)
        .toList();

    if (availableMaterials.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No available materials found. Please add some materials first.',
          ),
        ),
      );
      return;
    }

    try {
      await mealPlansProvider.generateWeeklyMealPlans(
        mealPlansProvider.selectedDate,
        availableMaterials,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Weekly meal plans generated successfully!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate weekly plans: $e')),
        );
      }
    }
  }
}
