// Custom Meal Generation Dialog for creating meals with specific materials and preferences
// Allows users to select materials, meal type, and dietary restrictions

import 'package:flutter/material.dart';
import '../../models/models.dart' as models;
import '../../utils/utils.dart';
import '../../services/services.dart';

class CustomMealGenerationDialog extends StatefulWidget {
  final List<models.Material> availableMaterials;
  final Function(models.Meal) onMealGenerated;
  final models.MealType? initialMealType;

  const CustomMealGenerationDialog({
    super.key,
    required this.availableMaterials,
    required this.onMealGenerated,
    this.initialMealType,
  });

  @override
  State<CustomMealGenerationDialog> createState() =>
      _CustomMealGenerationDialogState();
}

class _CustomMealGenerationDialogState extends State<CustomMealGenerationDialog>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Selected data
  final Set<String> _selectedMaterialIds = {};
  models.MealType _selectedMealType = models.MealType.lunch;
  final Set<String> _selectedDietaryRestrictions = {};
  final Set<String> _selectedCuisineTypes = {};

  // Form data
  String _mealName = '';
  String _mealDescription = '';
  int _preparationTime = 30;
  int _targetCalories = 500;

  // State
  bool _isGenerating = false;
  String? _errorMessage;

  // Available options
  final List<String> _dietaryRestrictions = [
    'Vegetarian',
    'Vegan',
    'Gluten-Free',
    'Dairy-Free',
    'Nut-Free',
    'Low-Carb',
    'Low-Fat',
    'High-Protein',
  ];

  final List<String> _cuisineTypes = [
    'Italian',
    'Asian',
    'Mexican',
    'Mediterranean',
    'American',
    'Indian',
    'French',
    'Thai',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    if (widget.initialMealType != null) {
      _selectedMealType = widget.initialMealType!;
    }

    // Pre-select some materials if available
    if (widget.availableMaterials.length >= 2) {
      _selectedMaterialIds.addAll(
        widget.availableMaterials.take(2).map((m) => m.id),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Tab Bar
            _buildTabBar(),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMaterialSelectionTab(),
                  _buildMealTypeTab(),
                  _buildPreferencesTab(),
                  _buildDetailsTab(),
                ],
              ),
            ),

            // Actions
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.tune, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Custom Meal Generation', style: AppTypography.titleLarge),
              Text(
                'Create a meal with your selected materials and preferences',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(icon: Icon(Icons.inventory), text: 'Materials'),
        Tab(icon: Icon(Icons.restaurant), text: 'Meal Type'),
        Tab(icon: Icon(Icons.favorite), text: 'Preferences'),
        Tab(icon: Icon(Icons.info), text: 'Details'),
      ],
    );
  }

  Widget _buildMaterialSelectionTab() {
    final selectedMaterials = widget.availableMaterials
        .where((m) => _selectedMaterialIds.contains(m.id))
        .toList();

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '${_selectedMaterialIds.length} materials selected. '
                    'Select at least 2 materials to generate a meal.',
                    style: AppTypography.bodyMedium,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Selected materials chips
          if (selectedMaterials.isNotEmpty) ...[
            Text('Selected Materials:', style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              children: selectedMaterials.map((material) {
                return Chip(
                  avatar: Text(material.category.emoji),
                  label: Text(material.name),
                  onDeleted: () {
                    setState(() {
                      _selectedMaterialIds.remove(material.id);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // Available materials list
          Text('Available Materials:', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.sm),

          Expanded(
            child: ListView.builder(
              itemCount: widget.availableMaterials.length,
              itemBuilder: (context, index) {
                final material = widget.availableMaterials[index];
                final isSelected = _selectedMaterialIds.contains(material.id);

                return CheckboxListTile(
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedMaterialIds.add(material.id);
                      } else {
                        _selectedMaterialIds.remove(material.id);
                      }
                    });
                  },
                  title: Text(material.name),
                  subtitle: Text(material.category.displayName),
                  secondary: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.getMaterialCategoryColor(
                        material.category.toString().split('.').last,
                      ).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
                    ),
                    child: Center(child: Text(material.category.emoji)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealTypeTab() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Meal Type:', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.md),

          ...models.MealType.values.map((mealType) {
            return Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ListTile(
                leading: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMealType = mealType;
                    });
                  },
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedMealType == mealType
                            ? AppColors.primary
                            : AppColors.surfaceVariant,
                        width: 2,
                      ),
                    ),
                    child: _selectedMealType == mealType
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
                title: Row(
                  children: [
                    Text(mealType.emoji),
                    const SizedBox(width: AppSpacing.sm),
                    Text(mealType.displayName),
                  ],
                ),
                subtitle: Text(mealType.timeRange),
                onTap: () {
                  setState(() {
                    _selectedMealType = mealType;
                  });
                },
              ),
            );
          }),

          const SizedBox(height: AppSpacing.lg),

          // Preparation time and calories
          Text('Meal Parameters:', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.md),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.timer, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: Text('Preparation Time')),
                      Text('$_preparationTime min'),
                    ],
                  ),
                  Slider(
                    value: _preparationTime.toDouble(),
                    min: 10,
                    max: 120,
                    divisions: 11,
                    onChanged: (value) {
                      setState(() {
                        _preparationTime = value.round();
                      });
                    },
                  ),

                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: Text('Target Calories')),
                      Text('$_targetCalories cal'),
                    ],
                  ),
                  Slider(
                    value: _targetCalories.toDouble(),
                    min: 200,
                    max: 1000,
                    divisions: 16,
                    onChanged: (value) {
                      setState(() {
                        _targetCalories = value.round();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesTab() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dietary Restrictions
            Text('Dietary Restrictions:', style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.sm),

            ...List.generate(_dietaryRestrictions.length, (index) {
              final restriction = _dietaryRestrictions[index];
              return CheckboxListTile(
                title: Text(restriction),
                value: _selectedDietaryRestrictions.contains(restriction),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedDietaryRestrictions.add(restriction);
                    } else {
                      _selectedDietaryRestrictions.remove(restriction);
                    }
                  });
                },
                dense: true,
              );
            }),

            const SizedBox(height: AppSpacing.lg),

            // Cuisine Types
            Text('Cuisine Preferences:', style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.sm),

            Wrap(
              spacing: AppSpacing.xs,
              children: _cuisineTypes.map((cuisine) {
                final isSelected = _selectedCuisineTypes.contains(cuisine);
                return FilterChip(
                  label: Text(cuisine),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCuisineTypes.add(cuisine);
                      } else {
                        _selectedCuisineTypes.remove(cuisine);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsTab() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Meal Details (Optional):', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.md),

          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Meal Name',
              hintText: 'Leave empty for auto-generated name',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => _mealName = value,
          ),

          const SizedBox(height: AppSpacing.md),

          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Leave empty for auto-generated description',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            onChanged: (value) => _mealDescription = value,
          ),

          const SizedBox(height: AppSpacing.lg),

          // Generation Summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Generation Summary:', style: AppTypography.titleMedium),
                  const SizedBox(height: AppSpacing.sm),

                  _buildSummaryRow(
                    'Materials',
                    '${_selectedMaterialIds.length} selected',
                  ),
                  _buildSummaryRow('Meal Type', _selectedMealType.displayName),
                  _buildSummaryRow('Prep Time', '$_preparationTime minutes'),
                  _buildSummaryRow('Target Calories', '$_targetCalories cal'),

                  if (_selectedDietaryRestrictions.isNotEmpty)
                    _buildSummaryRow(
                      'Dietary',
                      _selectedDietaryRestrictions.join(', '),
                    ),

                  if (_selectedCuisineTypes.isNotEmpty)
                    _buildSummaryRow(
                      'Cuisine',
                      _selectedCuisineTypes.join(', '),
                    ),
                ],
              ),
            ),
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: AppColors.error),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(_errorMessage!)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text('$label:', style: AppTypography.bodySmall),
          ),
          Expanded(child: Text(value, style: AppTypography.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildActions() {
    final canGenerate = _selectedMaterialIds.length >= 2;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Row(
        children: [
          TextButton(
            onPressed: _isGenerating ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),

          const Spacer(),

          ElevatedButton.icon(
            onPressed: canGenerate && !_isGenerating ? _generateMeal : null,
            icon: _isGenerating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(_isGenerating ? 'Generating...' : 'Generate Meal'),
          ),
        ],
      ),
    );
  }

  Future<void> _generateMeal() async {
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    try {
      final selectedMaterials = widget.availableMaterials
          .where((m) => _selectedMaterialIds.contains(m.id))
          .toList();

      final mealGeneratorService = MealGeneratorService();

      final meal = await mealGeneratorService.generateCustomMealEnhanced(
        materials: selectedMaterials,
        mealType: _selectedMealType,
        dietaryRestrictions: _selectedDietaryRestrictions.toList(),
        cuisinePreferences: _selectedCuisineTypes.toList(),
        targetCalories: _targetCalories,
        preparationTime: _preparationTime,
        customName: _mealName.isEmpty ? null : _mealName,
        customDescription: _mealDescription.isEmpty ? null : _mealDescription,
      );

      if (mounted) {
        widget.onMealGenerated(meal);
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Custom meal "${meal.name}" generated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to generate meal: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }
}
