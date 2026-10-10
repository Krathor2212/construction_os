import '../entities/material_consumption.dart';
import '../entities/material_inventory_summary.dart';
import '../entities/material_receipt.dart';
import '../entities/material_wastage.dart';

class MaterialInventoryCalculator {
  List<MaterialInventorySummary> calculate({
    required List<MaterialReceipt> receipts,
    required List<MaterialConsumption> consumptions,
    required List<MaterialWastage> wastage,
  }) {
    final totals = <String, _InventoryTotals>{};

    for (final receipt in receipts) {
      final total = totals.putIfAbsent(
        receipt.materialId,
        () => _InventoryTotals(unit: receipt.unit),
      );
      total.received += receipt.quantity;
    }
    for (final consumption in consumptions) {
      final total = totals.putIfAbsent(
        consumption.materialId,
        () => _InventoryTotals(unit: consumption.unit),
      );
      total.consumed += consumption.quantity;
    }
    for (final item in wastage) {
      final total = totals.putIfAbsent(
        item.materialId,
        () => _InventoryTotals(unit: item.unit),
      );
      total.wasted += item.quantity;
    }

    return totals.entries
        .map(
          (entry) => MaterialInventorySummary(
            materialId: entry.key,
            unit: entry.value.unit,
            receivedQuantity: entry.value.received,
            consumedQuantity: entry.value.consumed,
            wastedQuantity: entry.value.wasted,
          ),
        )
        .toList()
      ..sort((a, b) => a.materialId.compareTo(b.materialId));
  }
}

class _InventoryTotals {
  _InventoryTotals({required this.unit});

  final String unit;
  double received = 0;
  double consumed = 0;
  double wasted = 0;
}
