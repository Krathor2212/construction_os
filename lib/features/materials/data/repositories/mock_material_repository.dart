import '../../domain/entities/material.dart';
import '../../domain/repositories/material_repository.dart';

class MockMaterialRepository implements MaterialRepository {
  final List<Material> _materials = [
    Material(
      id: 'material-001',
      name: 'OPC Cement 53 Grade',
      category: MaterialCategory.cement,
      unit: MaterialUnit.bag,
      description: '53 grade ordinary Portland cement.',
    ),
    Material(
      id: 'material-002',
      name: 'TMT Steel 12mm',
      category: MaterialCategory.steel,
      unit: MaterialUnit.tonne,
      description: 'TMT reinforcement steel.',
    ),
    Material(
      id: 'material-003',
      name: 'River Sand',
      category: MaterialCategory.sand,
      unit: MaterialUnit.cubicMeter,
    ),
    Material(
      id: 'material-004',
      name: 'M-Sand',
      category: MaterialCategory.sand,
      unit: MaterialUnit.cubicMeter,
    ),
    Material(
      id: 'material-005',
      name: '20mm Aggregate',
      category: MaterialCategory.aggregate,
      unit: MaterialUnit.cubicMeter,
    ),
    Material(
      id: 'material-006',
      name: 'Red Clay Brick',
      category: MaterialCategory.bricks,
      unit: MaterialUnit.piece,
    ),
    Material(
      id: 'material-007',
      name: 'Electrical Conduit 20mm',
      category: MaterialCategory.electrical,
      unit: MaterialUnit.meter,
    ),
    Material(
      id: 'material-008',
      name: 'PVC Pipe 1 inch',
      category: MaterialCategory.plumbing,
      unit: MaterialUnit.meter,
    ),
    Material(
      id: 'material-009',
      name: 'Floor Tile 2x4 ft',
      category: MaterialCategory.flooring,
      unit: MaterialUnit.squareMeter,
    ),
    Material(
      id: 'material-010',
      name: 'Interior Wall Paint',
      category: MaterialCategory.paint,
      unit: MaterialUnit.liter,
    ),
  ];

  @override
  Future<List<Material>> getMaterials() async {
    return List.unmodifiable(_materials);
  }

  @override
  Future<Material> getMaterial(String id) async {
    return _materials.firstWhere(
      (material) => material.id == id,
    );
  }

  @override
  Future<Material> createMaterial(Material material) async {
    _materials.add(material);
    return material;
  }

  @override
  Future<Material> updateMaterial(Material material) async {
    final index = _materials.indexWhere(
      (item) => item.id == material.id,
    );

    if (index == -1) {
      throw StateError(
        'Material not found: ${material.id}',
      );
    }

    _materials[index] = material;
    return material;
  }

  @override
  Future<void> deleteMaterial(String id) async {
    _materials.removeWhere(
      (material) => material.id == id,
    );
  }
}