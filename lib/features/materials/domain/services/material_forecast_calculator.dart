import '../entities/material_forecast.dart';
import '../entities/material_inventory_summary.dart';
import '../entities/material_requirement.dart';

class MaterialForecastCalculator {
  List<MaterialForecast> calculate({
    required List<MaterialRequirement> requirements,
    required List<MaterialInventorySummary> inventory,
  }) {
    final grouped = <String, _ForecastTotals>{};
    for (final requirement in requirements) {
      final total = grouped.putIfAbsent(
        requirement.materialId,
        () => _ForecastTotals(unit: requirement.unit),
      );
      total.required += requirement.quantity;
    }
    for (final stock in inventory) {
      final total = grouped.putIfAbsent(
        stock.materialId,
        () => _ForecastTotals(unit: stock.unit),
      );
      total.received += stock.receivedQuantity;
      total.available += stock.availableQuantity;
    }
    return grouped.entries
        .map(
          (entry) => MaterialForecast(
            materialId: entry.key,
            unit: entry.value.unit,
            requiredQuantity: entry.value.required,
            receivedQuantity: entry.value.received,
            availableQuantity: entry.value.available,
            projectedShortfall: entry.value.required - entry.value.available,
          ),
        )
        .toList()
      ..sort((a, b) => a.materialId.compareTo(b.materialId));
  }
}

class _ForecastTotals {
  _ForecastTotals({required this.unit});

  final String unit;
  double required = 0;
  double received = 0;
  double available = 0;
}
