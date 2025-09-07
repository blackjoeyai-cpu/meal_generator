// Material service for managing ingredients and raw materials
// Handles CRUD operations for materials used in meal generation

import 'dart:convert';
import '../models/models.dart';
import 'database_service.dart';

class MaterialService {
  final DatabaseService _db = DatabaseService.instance;

  // Get all materials
  Future<List<Material>> getAllMaterials() async {
    try {
      final List<Map<String, dynamic>> maps = await _db.query('materials');
      return maps.map((map) => _materialFromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to get materials: $e');
    }
  }

  // Get materials by category
  Future<List<Material>> getMaterialsByCategory(
    MaterialCategory category,
  ) async {
    try {
      final categoryName = category.toString().split('.').last;
      final List<Map<String, dynamic>> maps = await _db.query(
        'materials',
        where: 'category = ?',
        whereArgs: [categoryName],
      );
      return maps.map((map) => _materialFromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to get materials by category: $e');
    }
  }

  // Get only available materials
  Future<List<Material>> getAvailableMaterials() async {
    try {
      final List<Map<String, dynamic>> maps = await _db.query(
        'materials',
        where: 'is_available = ?',
        whereArgs: [1],
      );
      return maps.map((map) => _materialFromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to get available materials: $e');
    }
  }

  // Search materials by name
  Future<List<Material>> searchMaterials(String query) async {
    try {
      final List<Map<String, dynamic>> maps = await _db.query(
        'materials',
        where: 'name LIKE ? OR description LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
      );
      return maps.map((map) => _materialFromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to search materials: $e');
    }
  }

  // Get material by ID
  Future<Material?> getMaterialById(String id) async {
    try {
      final List<Map<String, dynamic>> maps = await _db.query(
        'materials',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return _materialFromMap(maps.first);
    } catch (e) {
      throw Exception('Failed to get material by ID: $e');
    }
  }

  // Add a new material
  Future<void> addMaterial(Material material) async {
    try {
      await _db.insert('materials', _materialToMap(material));
    } catch (e) {
      throw Exception('Failed to add material: $e');
    }
  }

  // Update an existing material
  Future<void> updateMaterial(Material material) async {
    try {
      final rowsAffected = await _db.update(
        'materials',
        _materialToMap(material),
        where: 'id = ?',
        whereArgs: [material.id],
      );

      if (rowsAffected == 0) {
        throw Exception('Material not found');
      }
    } catch (e) {
      throw Exception('Failed to update material: $e');
    }
  }

  // Update material availability
  Future<void> updateMaterialAvailability(
    String materialId,
    bool isAvailable,
  ) async {
    try {
      final rowsAffected = await _db.update(
        'materials',
        {'is_available': isAvailable ? 1 : 0},
        where: 'id = ?',
        whereArgs: [materialId],
      );

      if (rowsAffected == 0) {
        throw Exception('Material not found');
      }
    } catch (e) {
      throw Exception('Failed to update material availability: $e');
    }
  }

  // Delete a material
  Future<void> deleteMaterial(String materialId) async {
    try {
      final rowsAffected = await _db.delete(
        'materials',
        where: 'id = ?',
        whereArgs: [materialId],
      );

      if (rowsAffected == 0) {
        throw Exception('Material not found');
      }
    } catch (e) {
      throw Exception('Failed to delete material: $e');
    }
  }

  // Bulk insert materials (useful for seeding data)
  Future<void> addMaterials(List<Material> materials) async {
    try {
      await _db.transaction((txn) async {
        for (final material in materials) {
          await txn.insert('materials', _materialToMap(material));
        }
      });
    } catch (e) {
      throw Exception('Failed to add materials: $e');
    }
  }

  // Get materials count by category
  Future<Map<MaterialCategory, int>> getMaterialsCountByCategory() async {
    try {
      final List<Map<String, dynamic>> result = await _db.rawQuery('''
        SELECT category, COUNT(*) as count 
        FROM materials 
        GROUP BY category
      ''');

      final Map<MaterialCategory, int> counts = {};

      for (final row in result) {
        final categoryStr = row['category'] as String;
        final count = row['count'] as int;

        try {
          final category = MaterialCategory.values.firstWhere(
            (e) => e.toString().split('.').last == categoryStr,
          );
          counts[category] = count;
        } catch (e) {
          // Skip unknown categories
        }
      }

      return counts;
    } catch (e) {
      throw Exception('Failed to get materials count by category: $e');
    }
  }

  // Get available materials count
  Future<int> getAvailableMaterialsCount() async {
    try {
      final List<Map<String, dynamic>> result = await _db.rawQuery('''
        SELECT COUNT(*) as count 
        FROM materials 
        WHERE is_available = 1
      ''');

      return result.first['count'] as int;
    } catch (e) {
      throw Exception('Failed to get available materials count: $e');
    }
  }

  // Toggle material availability
  Future<void> toggleMaterialAvailability(String materialId) async {
    try {
      final material = await getMaterialById(materialId);
      if (material == null) {
        throw Exception('Material not found');
      }

      await updateMaterialAvailability(materialId, !material.isAvailable);
    } catch (e) {
      throw Exception('Failed to toggle material availability: $e');
    }
  }

  // Convert Material to database map
  Map<String, dynamic> _materialToMap(Material material) {
    return {
      'id': material.id,
      'name': material.name,
      'category': material.category.toString().split('.').last,
      'nutritional_info': jsonEncode(material.nutritionalInfo),
      'is_available': material.isAvailable ? 1 : 0,
      'description': material.description,
      'image_url': material.imageUrl,
    };
  }

  // Convert database map to Material (public method)
  Material materialFromMap(Map<String, dynamic> map) {
    return _materialFromMap(map);
  }

  // Convert database map to Material
  Material _materialFromMap(Map<String, dynamic> map) {
    return Material(
      id: map['id'] as String,
      name: map['name'] as String,
      category: MaterialCategory.values.firstWhere(
        (e) => e.toString().split('.').last == map['category'],
      ),
      nutritionalInfo: map['nutritional_info'] != null
          ? List<String>.from(jsonDecode(map['nutritional_info'] as String))
          : [],
      isAvailable: (map['is_available'] as int) == 1,
      description: map['description'] as String?,
      imageUrl: map['image_url'] as String?,
    );
  }
}
