import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_material_requirement_procurement_repository.dart';
import '../../domain/entities/material_requirement_procurement.dart';
import '../../domain/repositories/material_requirement_procurement_repository.dart';
import '../../domain/usecases/calculate_material_requirement_procurement.dart';
import 'material_requirement_providers.dart';

final materialRequirementProcurementRepositoryProvider =
    Provider<MaterialRequirementProcurementRepository>((ref) {
  return MockMaterialRequirementProcurementRepository();
});

final materialRequirementProcurementsProvider =
    FutureProvider.family<List<MaterialRequirementProcurement>, String>(
  (ref, materialRequirementId) async {
    final repository =
        ref.watch(materialRequirementProcurementRepositoryProvider);

    return repository.getProcurements(materialRequirementId);
  },
);

final materialRequirementProcurementsByPurchaseOrderItemProvider =
    FutureProvider.family<
        List<MaterialRequirementProcurement>,
        String>(
  (ref, purchaseOrderItemId) async {
    final repository =
        ref.watch(materialRequirementProcurementRepositoryProvider);

    return repository.getProcurementsByPurchaseOrderItem(
      purchaseOrderItemId,
    );
  },
);

final calculateMaterialRequirementProcurementProvider =
    Provider<CalculateMaterialRequirementProcurement>((ref) {
  return const CalculateMaterialRequirementProcurement();
});

final materialRequirementProcurementSummaryProvider =
    FutureProvider.family<
        MaterialRequirementProcurementSummary,
        String>(
  (ref, materialRequirementId) async {
    final requirement = await ref.watch(
      materialRequirementProvider(materialRequirementId).future,
    );

    final procurements = await ref.watch(
      materialRequirementProcurementsProvider(
        materialRequirementId,
      ).future,
    );

    final calculator = ref.watch(
      calculateMaterialRequirementProcurementProvider,
    );

    return calculator.execute(
      requirement: requirement,
      procurements: procurements,
    );
  },
);