import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_material_consumption_repository.dart';
import '../../data/repositories/mock_material_receipt_repository.dart';
import '../../data/repositories/mock_material_wastage_repository.dart';
import '../../domain/entities/material_consumption.dart';
import '../../domain/entities/material_inventory_summary.dart';
import '../../domain/entities/material_receipt.dart';
import '../../domain/entities/material_wastage.dart';
import '../../domain/repositories/material_consumption_repository.dart';
import '../../domain/repositories/material_receipt_repository.dart';
import '../../domain/repositories/material_wastage_repository.dart';
import '../../domain/services/material_inventory_calculator.dart';

final materialReceiptRepositoryProvider = Provider<MaterialReceiptRepository>(
  (ref) => MockMaterialReceiptRepository(),
);

final materialConsumptionRepositoryProvider =
    Provider<MaterialConsumptionRepository>(
      (ref) => MockMaterialConsumptionRepository(),
    );

final materialWastageRepositoryProvider = Provider<MaterialWastageRepository>(
  (ref) => MockMaterialWastageRepository(),
);

final projectMaterialReceiptsProvider =
    FutureProvider.family<List<MaterialReceipt>, String>((ref, projectId) {
      return ref
          .watch(materialReceiptRepositoryProvider)
          .getReceipts(projectId: projectId);
    });

final projectMaterialConsumptionsProvider =
    FutureProvider.family<List<MaterialConsumption>, String>((ref, projectId) {
      return ref
          .watch(materialConsumptionRepositoryProvider)
          .getConsumptions(projectId: projectId);
    });

final projectMaterialWastageProvider =
    FutureProvider.family<List<MaterialWastage>, String>((ref, projectId) {
      return ref
          .watch(materialWastageRepositoryProvider)
          .getWastage(projectId: projectId);
    });

final projectMaterialInventoryProvider =
    FutureProvider.family<List<MaterialInventorySummary>, String>((
      ref,
      projectId,
    ) async {
      final results = await Future.wait([
        ref.watch(projectMaterialReceiptsProvider(projectId).future),
        ref.watch(projectMaterialConsumptionsProvider(projectId).future),
        ref.watch(projectMaterialWastageProvider(projectId).future),
      ]);

      return MaterialInventoryCalculator().calculate(
        receipts: results[0] as List<MaterialReceipt>,
        consumptions: results[1] as List<MaterialConsumption>,
        wastage: results[2] as List<MaterialWastage>,
      );
    });

final materialStockActionsProvider = Provider<MaterialStockActions>(
  (ref) => MaterialStockActions(ref),
);

class MaterialStockActions {
  MaterialStockActions(this._ref);

  final Ref _ref;

  Future<MaterialReceipt> createReceipt(MaterialReceipt receipt) async {
    final created = await _ref
        .read(materialReceiptRepositoryProvider)
        .createReceipt(receipt);
    _invalidate(receipt.projectId);
    return created;
  }

  Future<MaterialConsumption> createConsumption(
    MaterialConsumption consumption,
  ) async {
    final created = await _ref
        .read(materialConsumptionRepositoryProvider)
        .createConsumption(consumption);
    _invalidate(consumption.projectId);
    return created;
  }

  Future<MaterialWastage> createWastage(MaterialWastage wastage) async {
    final created = await _ref
        .read(materialWastageRepositoryProvider)
        .createWastage(wastage);
    _invalidate(wastage.projectId);
    return created;
  }

  void _invalidate(String projectId) {
    _ref
      ..invalidate(projectMaterialReceiptsProvider(projectId))
      ..invalidate(projectMaterialConsumptionsProvider(projectId))
      ..invalidate(projectMaterialWastageProvider(projectId))
      ..invalidate(projectMaterialInventoryProvider(projectId));
  }
}
