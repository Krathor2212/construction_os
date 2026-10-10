import 'package:flutter_test/flutter_test.dart';

import 'package:construction_os/features/materials/domain/entities/material_consumption.dart';
import 'package:construction_os/features/materials/domain/entities/material_receipt.dart';
import 'package:construction_os/features/materials/domain/entities/material_wastage.dart';
import 'package:construction_os/features/materials/domain/services/material_inventory_calculator.dart';

void main() {
  test('calculates available stock after consumption and wastage', () {
    final summary = MaterialInventoryCalculator().calculate(
      receipts: [
        MaterialReceipt(
          id: 'receipt-1',
          projectId: 'project-1',
          materialId: 'material-1',
          quantity: 100,
          unit: 'bag',
          receivedDate: DateTime(2026, 10, 1),
          receivedBy: 'Engineer',
        ),
      ],
      consumptions: [
        MaterialConsumption(
          id: 'consumption-1',
          projectId: 'project-1',
          materialId: 'material-1',
          quantity: 30,
          unit: 'bag',
          consumedDate: DateTime(2026, 10, 2),
          issuedTo: 'Crew',
        ),
      ],
      wastage: [
        MaterialWastage(
          id: 'wastage-1',
          projectId: 'project-1',
          materialId: 'material-1',
          quantity: 5,
          unit: 'bag',
          wastedDate: DateTime(2026, 10, 3),
          reason: MaterialWastageReason.damage,
          reportedBy: 'Supervisor',
        ),
      ],
    );

    expect(summary.single.receivedQuantity, 100);
    expect(summary.single.consumedQuantity, 30);
    expect(summary.single.wastedQuantity, 5);
    expect(summary.single.availableQuantity, 65);
  });

  test('keeps separate material balances', () {
    final summary = MaterialInventoryCalculator().calculate(
      receipts: [
        MaterialReceipt(
          id: 'receipt-1',
          projectId: 'project-1',
          materialId: 'material-2',
          quantity: 20,
          unit: 'kg',
          receivedDate: DateTime(2026, 10, 1),
          receivedBy: 'Engineer',
        ),
      ],
      consumptions: const [],
      wastage: const [],
    );

    expect(summary, hasLength(1));
    expect(summary.single.materialId, 'material-2');
    expect(summary.single.availableQuantity, 20);
  });
}
