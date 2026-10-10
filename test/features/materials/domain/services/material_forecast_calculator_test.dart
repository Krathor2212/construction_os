import 'package:flutter_test/flutter_test.dart';

import 'package:construction_os/features/materials/domain/entities/material_inventory_summary.dart';
import 'package:construction_os/features/materials/domain/entities/material_requirement.dart';
import 'package:construction_os/features/materials/domain/services/material_forecast_calculator.dart';

void main() {
  test('calculates material shortfall from requirements and stock', () {
    final result = MaterialForecastCalculator().calculate(
      requirements: [
        MaterialRequirement(
          id: 'requirement-1',
          projectId: 'project-1',
          materialId: 'material-1',
          quantity: 500,
          unit: 'bag',
        ),
      ],
      inventory: const [
        MaterialInventorySummary(
          materialId: 'material-1',
          unit: 'bag',
          receivedQuantity: 250,
          consumedQuantity: 40,
          wastedQuantity: 5,
        ),
      ],
    );

    expect(result.single.availableQuantity, 205);
    expect(result.single.projectedShortfall, 295);
    expect(result.single.isCovered, isFalse);
  });
}
