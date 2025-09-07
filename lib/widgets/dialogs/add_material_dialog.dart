// Add Material Dialog for creating new materials
// Provides form fields for material properties with validation

import 'package:flutter/material.dart';
import '../../models/models.dart' as models;
import '../../utils/utils.dart';

class AddMaterialDialog extends StatefulWidget {
  final Function(models.Material) onMaterialAdded;

  const AddMaterialDialog({
    super.key,
    required this.onMaterialAdded,
  });

  @override
  State<AddMaterialDialog> createState() => _AddMaterialDialogState();
}

class _AddMaterialDialogState extends State<AddMaterialDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _nutritionalInfoController = TextEditingController();

  models.MaterialCategory _selectedCategory = models.MaterialCategory.vegetables;
  bool _isAvailable = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _nutritionalInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.add_circle, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          const Text('Add New Material'),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Material Name
                _buildNameField(),
                const SizedBox(height: AppSpacing.md),

                // Category Selection
                _buildCategorySelection(),
                const SizedBox(height: AppSpacing.md),

                // Description
                _buildDescriptionField(),
                const SizedBox(height: AppSpacing.md),

                // Nutritional Information
                _buildNutritionalInfoField(),
                const SizedBox(height: AppSpacing.md),

                // Image URL
                _buildImageUrlField(),
                const SizedBox(height: AppSpacing.md),

                // Availability Toggle
                _buildAvailabilityToggle(),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSubmit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add Material'),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Material Name *',
        hintText: 'Enter material name',
        prefixIcon: const Icon(Icons.label),
        border: const OutlineInputBorder(),
      ),
      textCapitalization: TextCapitalization.words,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Material name is required';
        }
        if (value.trim().length < 2) {
          return 'Material name must be at least 2 characters';
        }
        if (value.trim().length > 50) {
          return 'Material name must be less than 50 characters';
        }
        return null;
      },
    );
  }

  Widget _buildCategorySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category *',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.surfaceVariant),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
          ),
          child: Column(
            children: models.MaterialCategory.values.map((category) {
              return ListTile(
                leading: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedCategory == category 
                            ? AppColors.primary 
                            : AppColors.surfaceVariant,
                        width: 2,
                      ),
                    ),
                    child: _selectedCategory == category
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
                    Text(category.emoji),
                    const SizedBox(width: AppSpacing.sm),
                    Text(category.displayName),
                  ],
                ),
                subtitle: Text(_getCategoryDescription(category)),
                dense: true,
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Description',
        hintText: 'Optional description of the material',
        prefixIcon: Icon(Icons.description),
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      maxLength: 200,
      validator: (value) {
        if (value != null && value.length > 200) {
          return 'Description must be less than 200 characters';
        }
        return null;
      },
    );
  }

  Widget _buildNutritionalInfoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _nutritionalInfoController,
          decoration: const InputDecoration(
            labelText: 'Nutritional Information',
            hintText: 'Enter nutritional info separated by commas',
            prefixIcon: Icon(Icons.local_fire_department),
            border: OutlineInputBorder(),
            helperText: 'Example: High Protein, Low Fat, Vitamin C',
          ),
          maxLines: 2,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final items = value.split(',');
              if (items.length > 10) {
                return 'Maximum 10 nutritional info items allowed';
              }
              for (final item in items) {
                if (item.trim().length > 30) {
                  return 'Each nutritional info item must be less than 30 characters';
                }
              }
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Separate multiple items with commas',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildImageUrlField() {
    return TextFormField(
      controller: _imageUrlController,
      decoration: const InputDecoration(
        labelText: 'Image URL',
        hintText: 'Optional image URL for the material',
        prefixIcon: Icon(Icons.image),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.url,
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final uri = Uri.tryParse(value);
          if (uri == null || !uri.hasScheme) {
            return 'Please enter a valid URL';
          }
        }
        return null;
      },
    );
  }

  Widget _buildAvailabilityToggle() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.surfaceVariant),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
      ),
      child: SwitchListTile(
        title: const Text('Available'),
        subtitle: Text(
          _isAvailable
              ? 'This material is currently available for meal planning'
              : 'This material is not available for meal planning',
        ),
        value: _isAvailable,
        onChanged: (value) {
          setState(() {
            _isAvailable = value;
          });
        },
        secondary: Icon(
          _isAvailable ? Icons.check_circle : Icons.cancel,
          color: _isAvailable ? AppColors.success : AppColors.error,
        ),
      ),
    );
  }

  String _getCategoryDescription(models.MaterialCategory category) {
    switch (category) {
      case models.MaterialCategory.meat:
        return 'Beef, pork, lamb, and other red meats';
      case models.MaterialCategory.seafood:
        return 'Fish, shellfish, and other marine foods';
      case models.MaterialCategory.poultry:
        return 'Chicken, turkey, duck, and other birds';
      case models.MaterialCategory.vegetables:
        return 'Fresh and frozen vegetables';
      case models.MaterialCategory.grains:
        return 'Rice, pasta, bread, and cereals';
      case models.MaterialCategory.dairy:
        return 'Milk, cheese, yogurt, and dairy products';
      case models.MaterialCategory.spices:
        return 'Herbs, spices, and seasonings';
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Parse nutritional information
      final nutritionalInfo = _nutritionalInfoController.text
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();

      // Create new material
      final material = models.Material(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        category: _selectedCategory,
        nutritionalInfo: nutritionalInfo,
        isAvailable: _isAvailable,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        imageUrl: _imageUrlController.text.trim().isEmpty
            ? null
            : _imageUrlController.text.trim(),
      );

      // Call the callback function
      widget.onMaterialAdded(material);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${material.name} added successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add material: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}