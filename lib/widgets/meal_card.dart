// Meal card widget for displaying individual meal information
// Shows meal details with actions for editing, deleting, and viewing

import 'package:flutter/material.dart';
import '../models/models.dart' as models;
import '../utils/utils.dart';

class MealCard extends StatelessWidget {
  final models.Meal meal;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onReplace;
  final VoidCallback? onView;
  final bool showActions;
  final bool isCompact;

  const MealCard({
    super.key,
    required this.meal,
    this.onEdit,
    this.onDelete,
    this.onReplace,
    this.onView,
    this.showActions = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onView,
        child: isCompact ? _buildCompactCard() : _buildFullCard(),
      ),
    );
  }

  Widget _buildFullCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with meal type and actions
        _buildHeader(),

        // Main content
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meal name and description
              _buildMealInfo(),

              const SizedBox(height: AppSpacing.md),

              // Materials used
              _buildMaterialsSection(),

              const SizedBox(height: AppSpacing.md),

              // Meal stats (time, calories, etc.)
              _buildMealStats(),

              if (meal.instructions.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                _buildInstructions(),
              ],

              if (meal.tags.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                _buildTags(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactCard() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // Meal type indicator
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.getMealTypeColor(
                meal.mealType.toString().split('.').last,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
            ),
            child: Center(
              child: Text(
                meal.mealType.emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Meal info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name,
                  style: AppTypography.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  meal.description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(Icons.timer, size: 14, color: AppColors.textTertiary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${meal.preparationTime} min',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    if (meal.calories != null) ...[
                      const SizedBox(width: AppSpacing.md),
                      Icon(
                        Icons.local_fire_department,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '${meal.calories} cal',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Actions menu
          if (showActions)
            PopupMenuButton<String>(
              onSelected: _handleAction,
              itemBuilder: (context) => _buildActionMenuItems(),
              child: const Icon(Icons.more_vert),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.getMealTypeColor(
          meal.mealType.toString().split('.').last,
        ).withValues(alpha: 0.1),
      ),
      child: Row(
        children: [
          // Meal type badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.getMealTypeColor(
                meal.mealType.toString().split('.').last,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(meal.mealType.emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  meal.mealType.displayName,
                  style: AppTypography.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Creation date
          Text(
            _getFormattedDate(meal.createdAt),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          // Actions menu
          if (showActions)
            PopupMenuButton<String>(
              onSelected: _handleAction,
              itemBuilder: (context) => _buildActionMenuItems(),
              child: const Icon(Icons.more_vert),
            ),
        ],
      ),
    );
  }

  Widget _buildMealInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(meal.name, style: AppTypography.mealTitle),
        const SizedBox(height: AppSpacing.sm),
        Text(meal.description, style: AppTypography.mealDescription),
      ],
    );
  }

  Widget _buildMaterialsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ingredients', style: AppTypography.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: meal.materials.map((material) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.getMaterialCategoryColor(
                  material.category.toString().split('.').last,
                ).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    material.category.emoji,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(material.name, style: AppTypography.labelMedium),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMealStats() {
    return Row(
      children: [
        // Preparation time
        _buildStatItem(Icons.timer, '${meal.preparationTime} min', 'Prep time'),

        const SizedBox(width: AppSpacing.lg),

        // Calories
        if (meal.calories != null)
          _buildStatItem(
            Icons.local_fire_department,
            '${meal.calories}',
            'Calories',
          ),

        const SizedBox(width: AppSpacing.lg),

        // Ingredients count
        _buildStatItem(
          Icons.inventory_2,
          '${meal.materials.length}',
          'Ingredients',
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.xs),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: AppTypography.labelLarge),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Instructions', style: AppTypography.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
          ),
          child: Text(meal.instructions, style: AppTypography.bodyMedium),
        ),
      ],
    );
  }

  Widget _buildTags() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tags', style: AppTypography.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: meal.tags.map((tag) {
            return Chip(
              label: Text(tag, style: AppTypography.labelSmall),
              backgroundColor: AppColors.surfaceVariant,
            );
          }).toList(),
        ),
      ],
    );
  }

  List<PopupMenuEntry<String>> _buildActionMenuItems() {
    return [
      if (onView != null)
        const PopupMenuItem(
          value: 'view',
          child: ListTile(
            leading: Icon(Icons.visibility),
            title: Text('View Details'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      if (onEdit != null)
        const PopupMenuItem(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit),
            title: Text('Edit'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      if (onReplace != null)
        const PopupMenuItem(
          value: 'replace',
          child: ListTile(
            leading: Icon(Icons.swap_horiz),
            title: Text('Replace'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      const PopupMenuItem(
        value: 'duplicate',
        child: ListTile(
          leading: Icon(Icons.copy),
          title: Text('Duplicate'),
          contentPadding: EdgeInsets.zero,
        ),
      ),
      const PopupMenuItem(
        value: 'share',
        child: ListTile(
          leading: Icon(Icons.share),
          title: Text('Share'),
          contentPadding: EdgeInsets.zero,
        ),
      ),
      if (onDelete != null)
        const PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete, color: AppColors.error),
            title: Text('Delete'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
    ];
  }

  void _handleAction(String action) {
    switch (action) {
      case 'view':
        onView?.call();
        break;
      case 'edit':
        onEdit?.call();
        break;
      case 'replace':
        onReplace?.call();
        break;
      case 'delete':
        onDelete?.call();
        break;
      case 'duplicate':
        // Handle duplicate action
        break;
      case 'share':
        // Handle share action
        break;
    }
  }

  String _getFormattedDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final mealDate = DateTime(date.year, date.month, date.day);

    if (mealDate == today) {
      return 'Today';
    } else if (mealDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (mealDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}

// Compact meal card variant for lists
class CompactMealCard extends StatelessWidget {
  final models.Meal meal;
  final VoidCallback? onTap;
  final bool isSelected;

  const CompactMealCard({
    super.key,
    required this.meal,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected ? AppColors.selected : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              // Meal type icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.getMealTypeColor(
                    meal.mealType.toString().split('.').last,
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXS),
                ),
                child: Center(
                  child: Text(
                    meal.mealType.emoji,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              // Meal info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      style: AppTypography.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${meal.preparationTime} min • ${meal.materials.length} ingredients',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Selection indicator
              if (isSelected)
                Icon(Icons.check_circle, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
