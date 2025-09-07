// Application state provider managing global app state
// Central state management for the meal planner application

import 'package:flutter/foundation.dart';
import '../services/services.dart';

class AppProvider extends ChangeNotifier {
  // Services
  final MaterialService _materialService = MaterialService();
  final MealService _mealService = MealService();
  final MealPlanService _mealPlanService = MealPlanService();
  final MealGeneratorService _mealGeneratorService = MealGeneratorService();
  final SeedDataService _seedDataService = SeedDataService();

  // Current state
  DateTime _selectedDate = DateTime.now();
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  DateTime get selectedDate => _selectedDate;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Services getters
  MaterialService get materialService => _materialService;
  MealService get mealService => _mealService;
  MealPlanService get mealPlanService => _mealPlanService;
  MealGeneratorService get mealGeneratorService => _mealGeneratorService;
  SeedDataService get seedDataService => _seedDataService;

  // Initialize the application
  Future<void> initialize() async {
    if (_isInitialized) return;

    _setLoading(true);
    _clearError();

    try {
      // Initialize database
      await DatabaseService.instance.database;

      // Initialize seed data (materials and sample meals)
      await _seedDataService.initializeSeedData();

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _setError('Failed to initialize app: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Set selected date
  void setSelectedDate(DateTime date) {
    if (_selectedDate != date) {
      _selectedDate = date;
      notifyListeners();
    }
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
