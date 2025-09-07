// Materials provider for managing ingredients and material state
// Handles material selection, filtering, and availability

import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

class MaterialsProvider extends ChangeNotifier {
  final MaterialService _materialService = MaterialService();

  // State
  List<Material> _allMaterials = [];
  List<Material> _filteredMaterials = [];
  final Set<String> _selectedMaterialIds = {};
  MaterialCategory? _selectedCategory;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;
  bool _showOnlyAvailable = true;

  // Getters
  List<Material> get allMaterials => _allMaterials;
  List<Material> get filteredMaterials => _filteredMaterials;
  List<Material> get selectedMaterials => _allMaterials
      .where((material) => _selectedMaterialIds.contains(material.id))
      .toList();
  MaterialCategory? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get showOnlyAvailable => _showOnlyAvailable;
  int get selectedMaterialsCount => _selectedMaterialIds.length;

  // Load all materials
  Future<void> loadMaterials() async {
    _setLoading(true);
    _clearError();

    try {
      _allMaterials = await _materialService.getAllMaterials();
      _applyFilters();
    } catch (e) {
      _setError('Failed to load materials: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load available materials only
  Future<void> loadAvailableMaterials() async {
    _setLoading(true);
    _clearError();

    try {
      _allMaterials = await _materialService.getAvailableMaterials();
      _applyFilters();
    } catch (e) {
      _setError('Failed to load available materials: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Toggle material selection
  void toggleMaterialSelection(String materialId) {
    if (_selectedMaterialIds.contains(materialId)) {
      _selectedMaterialIds.remove(materialId);
    } else {
      _selectedMaterialIds.add(materialId);
    }
    notifyListeners();
  }

  // Select all filtered materials
  void selectAllFilteredMaterials() {
    for (final material in _filteredMaterials) {
      _selectedMaterialIds.add(material.id);
    }
    notifyListeners();
  }

  // Clear all selections
  void clearAllSelections() {
    _selectedMaterialIds.clear();
    notifyListeners();
  }

  // Set category filter
  void setCategoryFilter(MaterialCategory? category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      _applyFilters();
    }
  }

  // Set search query
  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      _applyFilters();
    }
  }

  // Toggle show only available materials
  void toggleShowOnlyAvailable() {
    _showOnlyAvailable = !_showOnlyAvailable;
    _applyFilters();
  }

  // Toggle material availability
  Future<void> toggleMaterialAvailability(String materialId) async {
    try {
      await _materialService.toggleMaterialAvailability(materialId);
      await loadMaterials(); // Reload to reflect changes
    } catch (e) {
      _setError('Failed to toggle material availability: $e');
    }
  }

  // Add new material
  Future<void> addMaterial(Material material) async {
    _setLoading(true);
    _clearError();

    try {
      await _materialService.addMaterial(material);
      await loadMaterials(); // Reload to include new material
    } catch (e) {
      _setError('Failed to add material: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update material
  Future<void> updateMaterial(Material material) async {
    _setLoading(true);
    _clearError();

    try {
      await _materialService.updateMaterial(material);
      await loadMaterials(); // Reload to reflect changes
    } catch (e) {
      _setError('Failed to update material: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Delete material
  Future<void> deleteMaterial(String materialId) async {
    _setLoading(true);
    _clearError();

    try {
      await _materialService.deleteMaterial(materialId);
      _selectedMaterialIds.remove(materialId); // Remove from selection
      await loadMaterials(); // Reload to reflect changes
    } catch (e) {
      _setError('Failed to delete material: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get materials count by category
  Future<Map<MaterialCategory, int>> getMaterialsCountByCategory() async {
    try {
      return await _materialService.getMaterialsCountByCategory();
    } catch (e) {
      _setError('Failed to get materials count: $e');
      return {};
    }
  }

  // Apply filters to materials list
  void _applyFilters() {
    List<Material> filtered = List.from(_allMaterials);

    // Filter by availability
    if (_showOnlyAvailable) {
      filtered = filtered.where((material) => material.isAvailable).toList();
    }

    // Filter by category
    if (_selectedCategory != null) {
      filtered = filtered
          .where((material) => material.category == _selectedCategory)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((material) {
        return material.name.toLowerCase().contains(query) ||
            (material.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Sort by name
    filtered.sort((a, b) => a.name.compareTo(b.name));

    _filteredMaterials = filtered;
    notifyListeners();
  }

  // Set loading state
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  // Set error message
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Clear error message
  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  // Clear error manually
  void clearError() {
    _clearError();
  }
}
