// Replace Meal Dialog for generating alternative meal options
// Allows users to replace existing meals with new alternatives

import 'package:flutter/material.dart';
import '../../models/models.dart' as models;
import '../../utils/utils.dart';
import '../../services/services.dart';

class ReplaceMealDialog extends StatefulWidget {
  final models.MealType mealType;
  final models.Meal? currentMeal;
  final List<models.Material> availableMaterials;
  final Function(models.Meal) onMealSelected;

  const ReplaceMealDialog({
    super.key,
    required this.mealType,
    this.currentMeal,
    required this.availableMaterials,
    required this.onMealSelected,
  });

  @override
  State<ReplaceMealDialog> createState() => _ReplaceMealDialogState();
}

class _ReplaceMealDialogState extends State<ReplaceMealDialog> {
  final MealGeneratorService _mealGeneratorService = MealGeneratorService();

  List<models.Meal> _alternativeMeals = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _generateAlternatives();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.refresh, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Replace ${widget.mealType.displayName}'),
                if (widget.currentMeal != null)
                  Text(
                    'Current: ${widget.currentMeal!.name}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.6,
        child: _buildContent(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton.icon(
              onPressed: _isLoading ? null : _generateAlternatives,
              icon: const Icon(Icons.refresh),
              label: const Text('Generate More'),
            ),
            const SizedBox(width: AppSpacing.sm),
            ElevatedButton(
              onPressed: _selectedIndex >= 0 ? _confirmSelection : null,
              child: const Text('Select'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: AppSpacing.md),
            Text('Generating alternative meals...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Failed to generate alternatives',
              style: AppTypography.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _errorMessage!,
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: _generateAlternatives,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_alternativeMeals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('No Alternatives Found', style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Unable to generate alternative meals with available materials.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: _generateAlternatives,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
          ),
          child: Row(
            children: [
              Text(widget.mealType.emoji),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '${_alternativeMeals.length} alternative ${widget.mealType.displayName.toLowerCase()} options available',
                  style: AppTypography.bodyMedium,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Alternatives list
        Expanded(
          child: ListView.builder(
            itemCount: _alternativeMeals.length,
            itemBuilder: (context, index) {
              final meal = _alternativeMeals[index];
              final isSelected = _selectedIndex == index;

              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : null,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedIndex = isSelected ? -1 : index;
                    });
                  },
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row
                        Row(
                          children: [
                            // Selection indicator
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.surfaceVariant,
                                  width: 2,
                                ),
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                  : null,
                            ),

                            const SizedBox(width: AppSpacing.md),

                            // Meal name and timing
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    meal.name,
                                    style: AppTypography.titleMedium,
                                  ),
                                  Text(
                                    '${meal.preparationTime} min • ${meal.calories ?? 'Unknown'} cal',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Meal type indicator
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.getMealTypeColor(
                                  meal.mealType.toString().split('.').last,
                                ).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusSM,
                                ),
                              ),
                              child: Text(
                                meal.mealType.emoji,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.sm),

                        // Description
                        Text(
                          meal.description,
                          style: AppTypography.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: AppSpacing.sm),

                        // Materials
                        Wrap(
                          spacing: AppSpacing.xs,
                          children: meal.materials.take(5).map((material) {
                            return Chip(
                              avatar: Text(material.category.emoji),
                              label: Text(material.name),
                              backgroundColor: AppColors.surfaceVariant,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            );
                          }).toList(),
                        ),

                        // Show more materials indicator
                        if (meal.materials.length > 5)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.xs),
                            child: Text(
                              '+${meal.materials.length - 5} more materials',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _generateAlternatives() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _selectedIndex = -1;
    });

    try {
      // Generate multiple meal alternatives
      final alternatives = await _mealGeneratorService.generateMeals(
        availableMaterials: widget.availableMaterials,
        mealType: widget.mealType,
        count: 5, // Generate 5 alternatives
      );

      setState(() {
        _alternativeMeals = alternatives;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to generate alternatives: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _confirmSelection() {
    if (_selectedIndex >= 0 && _selectedIndex < _alternativeMeals.length) {
      final selectedMeal = _alternativeMeals[_selectedIndex];
      widget.onMealSelected(selectedMeal);

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${widget.mealType.displayName} replaced with "${selectedMeal.name}"',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}
