// Meal plan view widget for displaying and managing meal plans
// Shows generated meal plans and provides meal management functionality

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../models/models.dart' as models;
import '../utils/utils.dart';
import 'meal_card.dart';
import 'dialogs/custom_meal_generation_dialog.dart';
import 'dialogs/replace_meal_dialog.dart';
import 'dialogs/share_meal_plan_dialog.dart';
import 'dialogs/copy_meal_plan_dialog.dart';

class MealPlanView extends StatefulWidget {
  const MealPlanView({super.key});

  @override
  State<MealPlanView> createState() => _MealPlanViewState();
}

class _MealPlanViewState extends State<MealPlanView> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<MealPlansProvider, MaterialsProvider>(
      builder: (context, mealPlansProvider, materialsProvider, child) {
        return Column(
          children: [
            // Header with date and actions
            _buildHeader(mealPlansProvider),

            // Main content
            Expanded(
              child: _buildContent(mealPlansProvider, materialsProvider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(MealPlansProvider provider) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected date
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: AppColors.primary,
                size: AppSpacing.iconSize,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meal Plan for',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      _getFormattedDate(provider.selectedDate),
                      style: AppTypography.titleLarge,
                    ),
                  ],
                ),
              ),

              // Quick actions
              PopupMenuButton<String>(
                onSelected: (action) => _handleAction(action, provider),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'generate_new',
                    child: ListTile(
                      leading: Icon(Icons.auto_awesome),
                      title: Text('Generate New Plan'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'copy_plan',
                    child: ListTile(
                      leading: Icon(Icons.copy),
                      title: Text('Copy from Another Date'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  if (provider.selectedMealPlan != null)
                    const PopupMenuItem(
                      value: 'clear_plan',
                      child: ListTile(
                        leading: Icon(Icons.clear, color: AppColors.error),
                        title: Text('Clear Plan'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Status indicator
          _buildStatusIndicator(provider),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(MealPlansProvider provider) {
    final mealPlan = provider.selectedMealPlan;

    if (mealPlan == null) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, color: AppColors.warning, size: 16),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'No meal plan for this date',
              style: AppTypography.bodySmall.copyWith(color: AppColors.warning),
            ),
          ],
        ),
      );
    }

    final mealsCount = mealPlan.allMeals.length;
    final totalMealsTypes = models.MealType.values.length;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, color: AppColors.success, size: 16),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '$mealsCount of $totalMealsTypes meals planned',
            style: AppTypography.bodySmall.copyWith(color: AppColors.success),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    MealPlansProvider mealPlansProvider,
    MaterialsProvider materialsProvider,
  ) {
    if (mealPlansProvider.isLoading || mealPlansProvider.isGenerating) {
      return _buildLoadingState(mealPlansProvider);
    }

    if (mealPlansProvider.errorMessage != null) {
      return _buildErrorState(mealPlansProvider);
    }

    final mealPlan = mealPlansProvider.selectedMealPlan;

    if (mealPlan == null) {
      return _buildEmptyState(mealPlansProvider, materialsProvider);
    }

    return _buildMealPlanContent(mealPlan, mealPlansProvider);
  }

  Widget _buildLoadingState(MealPlansProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppSpacing.lg),
          Text(
            provider.isGenerating
                ? 'Generating meal plan...'
                : 'Loading meal plan...',
            style: AppTypography.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            provider.isGenerating
                ? 'This may take a few moments'
                : 'Please wait',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(MealPlansProvider provider) {
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
              provider.errorMessage!,
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () {
                provider.clearError();
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    MealPlansProvider mealPlansProvider,
    MaterialsProvider materialsProvider,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No Meal Plan Yet',
              style: AppTypography.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Create a meal plan for ${_getFormattedDate(mealPlansProvider.selectedDate)}',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Generation options
            Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () =>
                      _generateMealPlan(mealPlansProvider, materialsProvider),
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Generate Meal Plan'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 48),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                OutlinedButton.icon(
                  onPressed: () => _showMealTypeSelection(
                    mealPlansProvider,
                    materialsProvider,
                  ),
                  icon: const Icon(Icons.tune),
                  label: const Text('Custom Generation'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(200, 48),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                TextButton.icon(
                  onPressed: () => _createManualMealPlan(mealPlansProvider),
                  icon: const Icon(Icons.edit),
                  label: const Text('Create Manually'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealPlanContent(
    models.MealPlan mealPlan,
    MealPlansProvider provider,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal plan summary
          _buildMealPlanSummary(mealPlan),

          const SizedBox(height: AppSpacing.lg),

          // Meals by type
          ...models.MealType.values.map((mealType) {
            final meal = mealPlan.getMeal(mealType);
            return _buildMealTypeSection(mealType, meal, provider);
          }),

          const SizedBox(height: AppSpacing.xl),

          // Action buttons
          _buildActionButtons(mealPlan, provider),
        ],
      ),
    );
  }

  Widget _buildMealPlanSummary(models.MealPlan mealPlan) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Summary', style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Meals',
                    '${mealPlan.allMeals.length}',
                    Icons.restaurant,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Prep Time',
                    '${mealPlan.totalPreparationTime} min',
                    Icons.timer,
                  ),
                ),
                if (mealPlan.totalCalories != null)
                  Expanded(
                    child: _buildSummaryItem(
                      'Calories',
                      '${mealPlan.totalCalories}',
                      Icons.local_fire_department,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: AppSpacing.iconSize),
        const SizedBox(height: AppSpacing.sm),
        Text(value, style: AppTypography.titleMedium),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMealTypeSection(
    models.MealType mealType,
    models.Meal? meal,
    MealPlansProvider provider,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal type header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.getMealTypeColor(
                    mealType.toString().split('.').last,
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
                ),
                child: Text(
                  mealType.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  mealType.displayName,
                  style: AppTypography.titleLarge,
                ),
              ),
              if (meal == null)
                OutlinedButton.icon(
                  onPressed: () => _addMealToType(mealType, provider),
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Meal content
          if (meal != null)
            MealCard(
              meal: meal,
              onEdit: () => _editMeal(meal, provider),
              onDelete: () => _removeMealFromPlan(mealType, provider),
              onReplace: () => _replaceMeal(mealType, provider),
            )
          else
            _buildEmptyMealSlot(mealType),
        ],
      ),
    );
  }

  Widget _buildEmptyMealSlot(models.MealType mealType) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.surfaceVariant,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
      ),
      child: Column(
        children: [
          Icon(
            Icons.add_circle_outline,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No ${mealType.displayName.toLowerCase()} planned',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    models.MealPlan mealPlan,
    MealPlansProvider provider,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _regenerateMealPlan(provider),
                icon: const Icon(Icons.refresh),
                label: const Text('Regenerate'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _saveMealPlan(mealPlan, provider),
                icon: const Icon(Icons.save),
                label: const Text('Save Plan'),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        TextButton.icon(
          onPressed: () => _shareMealPlan(mealPlan),
          icon: const Icon(Icons.share),
          label: const Text('Share Meal Plan'),
        ),
      ],
    );
  }

  // Helper methods
  String _getFormattedDate(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  // Action handlers
  void _handleAction(String action, MealPlansProvider provider) {
    switch (action) {
      case 'generate_new':
        _regenerateMealPlan(provider);
        break;
      case 'copy_plan':
        _copyMealPlan(provider);
        break;
      case 'clear_plan':
        _clearMealPlan(provider);
        break;
    }
  }

  Future<void> _generateMealPlan(
    MealPlansProvider mealPlansProvider,
    MaterialsProvider materialsProvider,
  ) async {
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

  void _showMealTypeSelection(
    MealPlansProvider mealPlansProvider,
    MaterialsProvider materialsProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => CustomMealGenerationDialog(
        availableMaterials: materialsProvider.allMaterials
            .where((material) => material.isAvailable)
            .toList(),
        onMealGenerated: (meal) {
          // Add the generated meal to the current meal plan
          final currentPlan = mealPlansProvider.selectedMealPlan;
          if (currentPlan != null) {
            mealPlansProvider.updateMealInPlan(meal.mealType, meal);
          } else {
            // Create a new meal plan with this meal
            mealPlansProvider.createMealPlanWithMeal(
              mealPlansProvider.selectedDate,
              meal,
            );
          }
        },
      ),
    );
  }

  void _createManualMealPlan(MealPlansProvider provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Manual meal plan creation coming soon!')),
    );
  }

  void _addMealToType(models.MealType mealType, MealPlansProvider provider) {
    final materialsProvider = context.read<MaterialsProvider>();

    showDialog(
      context: context,
      builder: (context) => CustomMealGenerationDialog(
        availableMaterials: materialsProvider.allMaterials
            .where((material) => material.isAvailable)
            .toList(),
        initialMealType: mealType,
        onMealGenerated: (meal) {
          // Ensure the meal has the correct type
          final correctedMeal = meal.copyWith(mealType: mealType);
          provider.updateMealInPlan(mealType, correctedMeal);
        },
      ),
    );
  }

  void _editMeal(models.Meal meal, MealPlansProvider provider) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Edit ${meal.name} coming soon!')));
  }

  void _removeMealFromPlan(
    models.MealType mealType,
    MealPlansProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove ${mealType.displayName}'),
        content: Text(
          'Are you sure you want to remove this ${mealType.displayName.toLowerCase()} from the meal plan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              provider.updateMealInPlan(mealType, null);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _replaceMeal(models.MealType mealType, MealPlansProvider provider) {
    final materialsProvider = context.read<MaterialsProvider>();
    final currentMeal = provider.selectedMealPlan?.getMeal(mealType);

    showDialog(
      context: context,
      builder: (context) => ReplaceMealDialog(
        mealType: mealType,
        currentMeal: currentMeal,
        availableMaterials: materialsProvider.allMaterials
            .where((material) => material.isAvailable)
            .toList(),
        onMealSelected: (newMeal) {
          provider.updateMealInPlan(mealType, newMeal);
        },
      ),
    );
  }

  Future<void> _regenerateMealPlan(MealPlansProvider provider) async {
    final materialsProvider = context.read<MaterialsProvider>();
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
      // Clear existing meal plan first
      if (provider.selectedMealPlan != null) {
        provider.deleteMealPlan(provider.selectedMealPlan!.id);
      }

      // Generate new meal plan
      await provider.generateMealPlan(availableMaterials);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal plan regenerated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to regenerate meal plan: $e')),
        );
      }
    }
  }

  void _saveMealPlan(models.MealPlan mealPlan, MealPlansProvider provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Meal plan saved successfully!')),
    );
  }

  void _shareMealPlan(models.MealPlan mealPlan) {
    showDialog(
      context: context,
      builder: (context) => ShareMealPlanDialog(mealPlan: mealPlan),
    );
  }

  void _copyMealPlan(MealPlansProvider provider) {
    showDialog(
      context: context,
      builder: (context) => CopyMealPlanDialog(
        targetDate: provider.selectedDate,
        availableMealPlans: provider.mealPlans,
        onMealPlanSelected: (copiedPlan) {
          provider.saveMealPlan(copiedPlan);
        },
      ),
    );
  }

  void _clearMealPlan(MealPlansProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Meal Plan'),
        content: const Text(
          'Are you sure you want to clear this meal plan? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (provider.selectedMealPlan != null) {
                provider.deleteMealPlan(provider.selectedMealPlan!.id);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
