// Application color system based on modern minimalist design
// Defines consistent color palette for the meal planner app

import 'package:flutter/material.dart';

class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFF2E7D32); // Deep Green
  static const Color primaryLight = Color(0xFF60AD5E); // Light Green
  static const Color primaryDark = Color(0xFF005005); // Dark Green

  // Secondary Colors
  static const Color secondary = Color(0xFFFF6F00); // Orange Accent
  static const Color secondaryLight = Color(0xFFFF9F40); // Light Orange
  static const Color secondaryDark = Color(0xFFC43E00); // Dark Orange

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Neutral Colors
  static const Color background = Color(0xFFFAFAFA); // Off-white
  static const Color surface = Color(0xFFFFFFFF); // Pure white
  static const Color surfaceVariant = Color(0xFFF5F5F5); // Light gray

  // Text Colors
  static const Color textPrimary = Color(0xFF1C1C1E); // Near black
  static const Color textSecondary = Color(0xFF6B6B6B); // Medium gray
  static const Color textTertiary = Color(0xFF9E9E9E); // Light gray
  static const Color textDisabled = Color(0xFFBDBDBD); // Very light gray

  // Interactive States
  static const Color hover = Color(0x0F000000); // 6% black overlay
  static const Color pressed = Color(0x1F000000); // 12% black overlay
  static const Color focused = Color(0x1F2E7D32); // 12% primary overlay
  static const Color selected = Color(0x1F2E7D32); // 12% primary overlay

  // Material category colors
  static const Color meatColor = Color(0xFFE57373); // Light red
  static const Color seafoodColor = Color(0xFF4FC3F7); // Light blue
  static const Color poultryColor = Color(0xFFFFB74D); // Light orange
  static const Color vegetablesColor = Color(0xFF81C784); // Light green
  static const Color grainsColor = Color(0xFFDCE775); // Light yellow-green
  static const Color dairyColor = Color(0xFFE1BEE7); // Light purple
  static const Color spicesColor = Color(0xFFBCAAA4); // Light brown

  // Meal type colors
  static const Color breakfastColor = Color(0xFFFFF59D); // Light yellow
  static const Color lunchColor = Color(0xFFFFCC02); // Bright yellow
  static const Color dinnerColor = Color(0xFF5C6BC0); // Light indigo
  static const Color snackColor = Color(0xFFFF8A65); // Light orange

  // Get color for material category
  static Color getMaterialCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'meat':
        return meatColor;
      case 'seafood':
        return seafoodColor;
      case 'poultry':
        return poultryColor;
      case 'vegetables':
        return vegetablesColor;
      case 'grains':
        return grainsColor;
      case 'dairy':
        return dairyColor;
      case 'spices':
        return spicesColor;
      default:
        return surfaceVariant;
    }
  }

  // Get color for meal type
  static Color getMealTypeColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return breakfastColor;
      case 'lunch':
        return lunchColor;
      case 'dinner':
        return dinnerColor;
      case 'snack':
        return snackColor;
      default:
        return surfaceVariant;
    }
  }

  // Create material color swatch for primary color
  static MaterialColor get primarySwatch {
    return MaterialColor(primary.toARGB32(), {
      50: Color(0xFFE8F5E8),
      100: Color(0xFFC8E6C9),
      200: Color(0xFFA5D6A7),
      300: Color(0xFF81C784),
      400: Color(0xFF66BB6A),
      500: primary,
      600: Color(0xFF43A047),
      700: primaryDark,
      800: Color(0xFF2E7D32),
      900: Color(0xFF1B5E20),
    });
  }
}
