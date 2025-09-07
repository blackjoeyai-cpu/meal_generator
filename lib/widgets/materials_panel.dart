// Materials panel widget for ingredient selection and management
// Allows users to browse, filter, and select available materials

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../models/models.dart' as models;
import '../utils/utils.dart';

class MaterialsPanel extends StatefulWidget {
  const MaterialsPanel({super.key});

  @override
  State<MaterialsPanel> createState() => _MaterialsPanelState();
}

class _MaterialsPanelState extends State<MaterialsPanel> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MaterialsProvider>(
      builder: (context, materialsProvider, child) {
        return Column(
          children: [
            // Search and filter header
            _buildSearchAndFilters(materialsProvider),

            // Materials list
            Expanded(child: _buildMaterialsList(materialsProvider)),

            // Selected materials summary
            if (materialsProvider.selectedMaterialsCount > 0)
              _buildSelectedMaterialsSummary(materialsProvider),
          ],
        );
      },
    );
  }

  Widget _buildSearchAndFilters(MaterialsProvider provider) {
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
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            onChanged: provider.setSearchQuery,
            decoration: InputDecoration(
              hintText: 'Search materials...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        provider.setSearchQuery('');
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Show all chip
                FilterChip(
                  label: const Text('All'),
                  selected: provider.selectedCategory == null,
                  onSelected: (_) => provider.setCategoryFilter(null),
                ),

                const SizedBox(width: AppSpacing.sm),

                // Category filter chips
                ...models.MaterialCategory.values.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(category.emoji),
                          const SizedBox(width: AppSpacing.xs),
                          Text(category.displayName),
                        ],
                      ),
                      selected: provider.selectedCategory == category,
                      onSelected: (_) => provider.setCategoryFilter(
                        provider.selectedCategory == category ? null : category,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Action buttons
          Row(
            children: [
              // Toggle availability filter
              FilterChip(
                label: Text('Available only'),
                selected: provider.showOnlyAvailable,
                onSelected: (_) => provider.toggleShowOnlyAvailable(),
              ),

              const Spacer(),

              // Selection actions
              if (provider.filteredMaterials.isNotEmpty) ...[
                TextButton(
                  onPressed: provider.selectAllFilteredMaterials,
                  child: const Text('Select All'),
                ),
                const SizedBox(width: AppSpacing.sm),
                TextButton(
                  onPressed: provider.clearAllSelections,
                  child: const Text('Clear All'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsList(MaterialsProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return _buildErrorWidget(provider);
    }

    if (provider.filteredMaterials.isEmpty) {
      return _buildEmptyState(provider);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: provider.filteredMaterials.length,
      itemBuilder: (context, index) {
        final material = provider.filteredMaterials[index];
        return _buildMaterialCard(material, provider);
      },
    );
  }

  Widget _buildMaterialCard(
    models.Material material,
    MaterialsProvider provider,
  ) {
    final isSelected = provider.selectedMaterials.contains(material);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () => provider.toggleMaterialSelection(material.id),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Selection checkbox
              Checkbox(
                value: isSelected,
                onChanged: (_) => provider.toggleMaterialSelection(material.id),
              ),

              const SizedBox(width: AppSpacing.md),

              // Material category icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.getMaterialCategoryColor(
                    material.category.toString().split('.').last,
                  ).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
                ),
                child: Center(
                  child: Text(
                    material.category.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              // Material info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(material.name, style: AppTypography.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      material.category.displayName,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (material.description != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        material.description!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (material.nutritionalInfo.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Wrap(
                        spacing: AppSpacing.xs,
                        children: material.nutritionalInfo.take(3).map((info) {
                          return Chip(
                            label: Text(info, style: AppTypography.labelSmall),
                            backgroundColor: AppColors.surfaceVariant,
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),

              // Availability toggle and actions
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Availability indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: material.isAvailable
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
                    ),
                    child: Text(
                      material.isAvailable ? 'Available' : 'Unavailable',
                      style: AppTypography.labelSmall.copyWith(
                        color: material.isAvailable
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Actions menu
                  PopupMenuButton<String>(
                    onSelected: (action) =>
                        _handleMaterialAction(action, material, provider),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'toggle_availability',
                        child: ListTile(
                          leading: Icon(
                            material.isAvailable
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          title: Text(
                            material.isAvailable
                                ? 'Mark Unavailable'
                                : 'Mark Available',
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Edit'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: AppColors.error),
                          title: Text('Delete'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                    child: const Icon(Icons.more_vert),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedMaterialsSummary(MaterialsProvider provider) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        border: Border(
          top: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '${provider.selectedMaterialsCount} materials selected',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _generateMealWithSelectedMaterials(provider),
            icon: const Icon(Icons.restaurant),
            label: const Text('Generate Meals'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(MaterialsProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Failed to load materials',
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
                provider.loadMaterials();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(MaterialsProvider provider) {
    final hasFilters =
        provider.selectedCategory != null ||
        provider.searchQuery.isNotEmpty ||
        provider.showOnlyAvailable;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilters ? Icons.search_off : Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              hasFilters ? 'No materials found' : 'No materials available',
              style: AppTypography.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              hasFilters
                  ? 'Try adjusting your search or filters'
                  : 'Add some materials to get started with meal planning',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            if (hasFilters)
              OutlinedButton(
                onPressed: () {
                  provider.setCategoryFilter(null);
                  provider.setSearchQuery('');
                  provider.toggleShowOnlyAvailable();
                  _searchController.clear();
                },
                child: const Text('Clear Filters'),
              )
            else
              ElevatedButton.icon(
                onPressed: _showAddMaterialDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Materials'),
              ),
          ],
        ),
      ),
    );
  }

  // Action handlers
  void _handleMaterialAction(
    String action,
    models.Material material,
    MaterialsProvider provider,
  ) {
    switch (action) {
      case 'toggle_availability':
        provider.toggleMaterialAvailability(material.id);
        break;
      case 'edit':
        _showEditMaterialDialog(material, provider);
        break;
      case 'delete':
        _showDeleteMaterialDialog(material, provider);
        break;
    }
  }

  void _generateMealWithSelectedMaterials(MaterialsProvider provider) {
    if (provider.selectedMaterials.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one material')),
      );
      return;
    }

    // Navigate to meal generation with selected materials
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Generating meals with ${provider.selectedMaterialsCount} selected materials',
        ),
      ),
    );
  }

  void _showAddMaterialDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add material dialog coming soon!')),
    );
  }

  void _showEditMaterialDialog(
    models.Material material,
    MaterialsProvider provider,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit ${material.name} coming soon!')),
    );
  }

  void _showDeleteMaterialDialog(
    models.Material material,
    MaterialsProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Material'),
        content: Text(
          'Are you sure you want to delete "${material.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              provider.deleteMaterial(material.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${material.name} deleted')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
