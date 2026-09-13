import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_material_repository.dart';
import '../../domain/entities/material.dart';
import '../../domain/repositories/material_repository.dart';

final materialRepositoryProvider = Provider<MaterialRepository>((ref) {
  return MockMaterialRepository();
});

final materialsProvider = FutureProvider<List<Material>>((ref) async {
  final repository = ref.watch(materialRepositoryProvider);

  return repository.getMaterials();
});

final materialProvider = FutureProvider.family<Material, String>(
  (ref, materialId) async {
    final repository = ref.watch(materialRepositoryProvider);

    return repository.getMaterial(materialId);
  },
);