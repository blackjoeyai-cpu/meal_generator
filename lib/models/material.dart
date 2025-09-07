// Material model for ingredients used in meal generation
// Represents a raw material/ingredient that can be used to create meals

enum MaterialCategory {
  meat,
  seafood,
  poultry,
  vegetables,
  grains,
  dairy,
  spices,
}

class Material {
  final String id;
  final String name;
  final MaterialCategory category;
  final List<String> nutritionalInfo;
  final bool isAvailable;
  final String? description;
  final String? imageUrl;

  const Material({
    required this.id,
    required this.name,
    required this.category,
    this.nutritionalInfo = const [],
    this.isAvailable = true,
    this.description,
    this.imageUrl,
  });

  // Factory constructor for creating Material from JSON/Map
  factory Material.fromJson(Map<String, dynamic> json) {
    return Material(
      id: json['id'] as String,
      name: json['name'] as String,
      category: MaterialCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
      ),
      nutritionalInfo: List<String>.from(json['nutritional_info'] ?? []),
      isAvailable: json['is_available'] as bool? ?? true,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }

  // Convert Material to JSON/Map for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.toString().split('.').last,
      'nutritional_info': nutritionalInfo,
      'is_available': isAvailable,
      'description': description,
      'image_url': imageUrl,
    };
  }

  // Create a copy of Material with modified fields
  Material copyWith({
    String? id,
    String? name,
    MaterialCategory? category,
    List<String>? nutritionalInfo,
    bool? isAvailable,
    String? description,
    String? imageUrl,
  }) {
    return Material(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      nutritionalInfo: nutritionalInfo ?? this.nutritionalInfo,
      isAvailable: isAvailable ?? this.isAvailable,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Material && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Material(id: $id, name: $name, category: $category, isAvailable: $isAvailable)';
  }
}

// Extension for MaterialCategory to get display names
extension MaterialCategoryExtension on MaterialCategory {
  String get displayName {
    switch (this) {
      case MaterialCategory.meat:
        return 'Meat';
      case MaterialCategory.seafood:
        return 'Seafood';
      case MaterialCategory.poultry:
        return 'Poultry';
      case MaterialCategory.vegetables:
        return 'Vegetables';
      case MaterialCategory.grains:
        return 'Grains';
      case MaterialCategory.dairy:
        return 'Dairy';
      case MaterialCategory.spices:
        return 'Spices';
    }
  }

  String get emoji {
    switch (this) {
      case MaterialCategory.meat:
        return '🥩';
      case MaterialCategory.seafood:
        return '🐟';
      case MaterialCategory.poultry:
        return '🐔';
      case MaterialCategory.vegetables:
        return '🥬';
      case MaterialCategory.grains:
        return '🌾';
      case MaterialCategory.dairy:
        return '🥛';
      case MaterialCategory.spices:
        return '🌿';
    }
  }
}
