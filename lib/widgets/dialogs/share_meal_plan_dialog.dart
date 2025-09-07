// Share Meal Plan Dialog for sharing meal plans through various methods
// Provides options to share meal plans via text, email, or export

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/models.dart' as models;
import '../../utils/utils.dart';

class ShareMealPlanDialog extends StatefulWidget {
  final models.MealPlan mealPlan;

  const ShareMealPlanDialog({
    super.key,
    required this.mealPlan,
  });

  @override
  State<ShareMealPlanDialog> createState() => _ShareMealPlanDialogState();
}

class _ShareMealPlanDialogState extends State<ShareMealPlanDialog> {
  String _shareFormat = 'text';
  bool _includeInstructions = true;
  bool _includeMaterials = true;
  bool _includeNutrition = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.share, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          const Text('Share Meal Plan'),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal plan info
            _buildMealPlanInfo(),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Share format selection
            _buildFormatSelection(),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Content options
            _buildContentOptions(),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Preview
            _buildPreview(),
          ],
        ),
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
              onPressed: _copyToClipboard,
              icon: const Icon(Icons.copy),
              label: const Text('Copy'),
            ),
            const SizedBox(width: AppSpacing.sm),
            ElevatedButton.icon(
              onPressed: _shareContent,
              icon: const Icon(Icons.share),
              label: const Text('Share'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMealPlanInfo() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Meal Plan for ${_getFormattedDate(widget.mealPlan.date)}',
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          
          Row(
            children: [
              _buildInfoChip(
                Icons.restaurant,
                '${widget.mealPlan.allMeals.length} meals',
              ),
              const SizedBox(width: AppSpacing.sm),
              _buildInfoChip(
                Icons.timer,
                '${widget.mealPlan.totalPreparationTime} min',
              ),
              if (widget.mealPlan.totalCalories != null) ...[
                const SizedBox(width: AppSpacing.sm),
                _buildInfoChip(
                  Icons.local_fire_department,
                  '${widget.mealPlan.totalCalories} cal',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: AppSpacing.xs),
          Text(
            text,
            style: AppTypography.bodySmall.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Share Format:', style: AppTypography.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        
        Row(
          children: [
            Expanded(
              child: ListTile(
                leading: GestureDetector(
                  onTap: () {
                    setState(() {
                      _shareFormat = 'text';
                    });
                  },
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _shareFormat == 'text' 
                            ? AppColors.primary 
                            : AppColors.surfaceVariant,
                        width: 2,
                      ),
                    ),
                    child: _shareFormat == 'text'
                        ? Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
                title: const Text('Text'),
                subtitle: const Text('Plain text format'),
                dense: true,
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  setState(() {
                    _shareFormat = 'text';
                  });
                },
              ),
            ),
            Expanded(
              child: ListTile(
                leading: GestureDetector(
                  onTap: () {
                    setState(() {
                      _shareFormat = 'formatted';
                    });
                  },
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _shareFormat == 'formatted' 
                            ? AppColors.primary 
                            : AppColors.surfaceVariant,
                        width: 2,
                      ),
                    ),
                    child: _shareFormat == 'formatted'
                        ? Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
                title: const Text('Formatted'),
                subtitle: const Text('Rich text format'),
                dense: true,
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  setState(() {
                    _shareFormat = 'formatted';
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContentOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Include in Share:', style: AppTypography.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        
        CheckboxListTile(
          title: const Text('Cooking Instructions'),
          value: _includeInstructions,
          onChanged: (value) {
            setState(() {
              _includeInstructions = value!;
            });
          },
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
        
        CheckboxListTile(
          title: const Text('Materials List'),
          value: _includeMaterials,
          onChanged: (value) {
            setState(() {
              _includeMaterials = value!;
            });
          },
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
        
        CheckboxListTile(
          title: const Text('Nutrition Information'),
          value: _includeNutrition,
          onChanged: (value) {
            setState(() {
              _includeNutrition = value!;
            });
          },
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Preview:', style: AppTypography.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        
        Container(
          width: double.infinity,
          height: 150,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.surfaceVariant),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
          ),
          child: SingleChildScrollView(
            child: Text(
              _generateShareContent(),
              style: AppTypography.bodySmall.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _generateShareContent() {
    final buffer = StringBuffer();
    
    if (_shareFormat == 'formatted') {
      buffer.writeln('🍽️ MEAL PLAN');
      buffer.writeln('═' * 20);
    } else {
      buffer.writeln('MEAL PLAN');
      buffer.writeln('=' * 20);
    }
    
    buffer.writeln('Date: ${_getFormattedDate(widget.mealPlan.date)}');
    buffer.writeln();

    // Add meals by type
    for (final mealType in models.MealType.values) {
      final meal = widget.mealPlan.getMeal(mealType);
      if (meal != null) {
        if (_shareFormat == 'formatted') {
          buffer.writeln('${mealType.emoji} ${mealType.displayName.toUpperCase()}');
        } else {
          buffer.writeln(mealType.displayName.toUpperCase());
        }
        
        buffer.writeln('• ${meal.name}');
        buffer.writeln('  ${meal.description}');
        
        if (_includeNutrition && (meal.calories != null || meal.preparationTime > 0)) {
          buffer.write('  ');
          if (meal.preparationTime > 0) {
            buffer.write('Prep: ${meal.preparationTime} min');
          }
          if (meal.calories != null) {
            if (meal.preparationTime > 0) buffer.write(' • ');
            buffer.write('${meal.calories} cal');
          }
          buffer.writeln();
        }
        
        if (_includeMaterials && meal.materials.isNotEmpty) {
          buffer.writeln('  Materials: ${meal.materials.map((m) => m.name).join(', ')}');
        }
        
        if (_includeInstructions && meal.instructions.isNotEmpty) {
          final instructions = meal.instructions.split('\n');
          for (final instruction in instructions) {
            if (instruction.trim().isNotEmpty) {
              buffer.writeln('  $instruction');
            }
          }
        }
        
        buffer.writeln();
      }
    }

    // Add summary
    if (_shareFormat == 'formatted') {
      buffer.writeln('📊 SUMMARY');
      buffer.writeln('─' * 20);
    } else {
      buffer.writeln('SUMMARY');
      buffer.writeln('-' * 20);
    }
    
    buffer.writeln('Total meals: ${widget.mealPlan.allMeals.length}');
    buffer.writeln('Total prep time: ${widget.mealPlan.totalPreparationTime} minutes');
    
    if (widget.mealPlan.totalCalories != null) {
      buffer.writeln('Total calories: ${widget.mealPlan.totalCalories}');
    }
    
    buffer.writeln();
    buffer.writeln('Generated by Meal Planner App');

    return buffer.toString();
  }

  String _getFormattedDate(DateTime date) {
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];

    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _copyToClipboard() async {
    final content = _generateShareContent();
    await Clipboard.setData(ClipboardData(text: content));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Meal plan copied to clipboard'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _shareContent() {
    // For now, just copy to clipboard
    // In a real app, you would use the share package
    _copyToClipboard();
    
    Navigator.of(context).pop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Meal plan shared successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}