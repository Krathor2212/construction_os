import 'package:flutter_test/flutter_test.dart';

import 'package:construction_os/features/materials/data/repositories/mock_material_consumption_repository.dart';
import 'package:construction_os/features/materials/data/repositories/mock_material_receipt_repository.dart';
import 'package:construction_os/features/materials/data/repositories/mock_material_wastage_repository.dart';

void main() {
  test('returns project receipts', () async {
    final receipts = await MockMaterialReceiptRepository().getReceipts(
      projectId: 'project-001',
    );
    expect(receipts, hasLength(1));
    expect(receipts.single.quantity, 250);
  });

  test('returns project consumptions', () async {
    final consumptions = await MockMaterialConsumptionRepository()
        .getConsumptions(projectId: 'project-001');
    expect(consumptions, hasLength(1));
    expect(consumptions.single.quantity, 40);
  });

  test('returns project wastage', () async {
    final wastage = await MockMaterialWastageRepository().getWastage(
      projectId: 'project-001',
    );
    expect(wastage, hasLength(1));
    expect(wastage.single.reason.name, 'damage');
  });
}
