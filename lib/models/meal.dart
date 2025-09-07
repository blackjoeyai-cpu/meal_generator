// Meal model representing a single meal with its ingredients and details
// Used to store information about generated or custom meals

import 'material.dart';

enum MealType { breakfast, lunch, dinner, snack }

class Meal {
  final String id;
  final String name;
  final String description;
  final List<Material> materials;
  final MealType mealType;
  final int preparationTime; // in minutes
  final String instructions;
  final DateTime createdAt;
  final String? imageUrl;
  final int? calories;
  final List<String> tags;

  const Meal({
    required this.id,
    required this.name,
    required this.description,
    required this.materials,
    required this.mealType,
    this.preparationTime = 0,
    this.instructions = '',
    required this.createdAt,
    this.imageUrl,
    this.calories,
    this.tags = const [],
  });

  // Factory constructor for creating Meal from JSON/Map
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      materials: (json['materials'] as List<dynamic>)
          .map(
            (materialJson) =>
                Material.fromJson(materialJson as Map<String, dynamic>),
          )
          .toList(),
      mealType: MealType.values.firstWhere(
        (e) => e.toString().split('.').last == json['meal_type'],
      ),
      preparationTime: json['preparation_time'] as int? ?? 0,
      instructions: json['instructions'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      imageUrl: json['image_url'] as String?,
      calories: json['calories'] as int?,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  // Convert Meal to JSON/Map for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'materials': materials.map((material) => material.toJson()).toList(),
      'meal_type': mealType.toString().split('.').last,
      'preparation_time': preparationTime,
      'instructions': instructions,
      'created_at': createdAt.toIso8601String(),
      'image_url': imageUrl,
      'calories': calories,
      'tags': tags,
    };
  }

  // Create a copy of Meal with modified fields
  Meal copyWith({
    String? id,
    String? name,
    String? description,
    List<Material>? materials,
    MealType? mealType,
    int? preparationTime,
    String? instructions,
    DateTime? createdAt,
    String? imageUrl,
    int? calories,
    List<String>? tags,
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      materials: materials ?? this.materials,
      mealType: mealType ?? this.mealType,
      preparationTime: preparationTime ?? this.preparationTime,
      instructions: instructions ?? this.instructions,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
      calories: calories ?? this.calories,
      tags: tags ?? this.tags,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Meal && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Meal(id: $id, name: $name, mealType: $mealType, materials: ${materials.length})';
  }
}

// Extension for MealType to get display names and properties
extension MealTypeExtension on MealType {
  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }

  String get emoji {
    switch (this) {
      case MealType.breakfast:
        return '🌅';
      case MealType.lunch:
        return '☀️';
      case MealType.dinner:
        return '🌙';
      case MealType.snack:
        return '🍿';
    }
  }

  // Typical time ranges for meal types
  String get timeRange {
    switch (this) {
      case MealType.breakfast:
        return '6:00 AM - 10:00 AM';
      case MealType.lunch:
        return '11:00 AM - 2:00 PM';
      case MealType.dinner:
        return '6:00 PM - 9:00 PM';
      case MealType.snack:
        return 'Anytime';
    }
  }
}
