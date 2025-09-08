// Edit Material Dialog for modifying existing materials
// Pre-populates form fields with existing material data

import 'package:flutter/material.dart';
import '../../models/models.dart' as models;
import '../../utils/utils.dart';

class EditMaterialDialog extends StatefulWidget {
  final models.Material material;
  final Function(models.Material) onMaterialUpdated;

  const EditMaterialDialog({
    super.key,
    required this.material,
    required this.onMaterialUpdated,
  });

  @override
  State<EditMaterialDialog> createState() => _EditMaterialDialogState();
}

class _EditMaterialDialogState extends State<EditMaterialDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _nutritionalInfoController;

  late models.MaterialCategory _selectedCategory;
  late bool _isAvailable;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _populateFields();
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _imageUrlController = TextEditingController();
    _nutritionalInfoController = TextEditingController();

    // Add listeners to detect changes
    _nameController.addListener(_onFieldChanged);
    _descriptionController.addListener(_onFieldChanged);
    _imageUrlController.addListener(_onFieldChanged);
    _nutritionalInfoController.addListener(_onFieldChanged);
  }

  void _populateFields() {
    _nameController.text = widget.material.name;
    _descriptionController.text = widget.material.description ?? '';
    _imageUrlController.text = widget.material.imageUrl ?? '';
    _nutritionalInfoController.text = widget.material.nutritionalInfo.join(
      ', ',
    );
    _selectedCategory = widget.material.category;
    _isAvailable = widget.material.isAvailable;
  }

  void _onFieldChanged() {
    setState(() {
      _hasChanges = _checkForChanges();
    });
  }

  bool _checkForChanges() {
    return _nameController.text.trim() != widget.material.name ||
        _descriptionController.text.trim() !=
            (widget.material.description ?? '') ||
        _imageUrlController.text.trim() != (widget.material.imageUrl ?? '') ||
        _nutritionalInfoController.text.trim() !=
            widget.material.nutritionalInfo.join(', ') ||
        _selectedCategory != widget.material.category ||
        _isAvailable != widget.material.isAvailable;
  }

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
          Icon(Icons.edit, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          const Text('Edit Material'),
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
                // Material ID display
                _buildMaterialIdDisplay(),
                const SizedBox(height: AppSpacing.md),

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

                // Changes indicator
                if (_hasChanges) _buildChangesIndicator(),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => _handleCancel(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading || !_hasChanges ? null : _handleSubmit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save Changes'),
        ),
      ],
    );
  }

  Widget _buildMaterialIdDisplay() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
      ),
      child: Row(
        children: [
          Icon(Icons.fingerprint, color: AppColors.textSecondary, size: 16),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'ID: ${widget.material.id}',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
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
                      _onFieldChanged();
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
                    _onFieldChanged();
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
            _onFieldChanged();
          });
        },
        secondary: Icon(
          _isAvailable ? Icons.check_circle : Icons.cancel,
          color: _isAvailable ? AppColors.success : AppColors.error,
        ),
      ),
    );
  }

  Widget _buildChangesIndicator() {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
      ),
      child: Row(
        children: [
          Icon(Icons.edit, color: AppColors.warning, size: 16),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'You have unsaved changes',
            style: AppTypography.bodySmall.copyWith(color: AppColors.warning),
          ),
        ],
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

  void _handleCancel() {
    if (_hasChanges) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard Changes?'),
          content: const Text(
            'You have unsaved changes. Are you sure you want to discard them?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Keep Editing'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close confirmation dialog
                Navigator.of(context).pop(); // Close edit dialog
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Discard'),
            ),
          ],
        ),
      );
    } else {
      Navigator.of(context).pop();
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

      // Create updated material
      final updatedMaterial = widget.material.copyWith(
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
      widget.onMaterialUpdated(updatedMaterial);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${updatedMaterial.name} updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update material: $e'),
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
