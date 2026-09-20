import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_material_requirement_repository.dart';
import '../../domain/entities/material_requirement.dart';
import '../../domain/repositories/material_requirement_repository.dart';

final materialRequirementRepositoryProvider =
    Provider<MaterialRequirementRepository>((ref) {
  return MockMaterialRequirementRepository();
});

final materialRequirementsProvider =
    FutureProvider.family<List<MaterialRequirement>, String>(
  (ref, projectId) async {
    final repository =
        ref.watch(materialRequirementRepositoryProvider);

    return repository.getRequirements(projectId);
  },
);

final materialRequirementProvider =
    FutureProvider.family<MaterialRequirement, String>(
  (ref, requirementId) async {
    final repository =
        ref.watch(materialRequirementRepositoryProvider);

    return repository.getRequirement(requirementId);
  },
);