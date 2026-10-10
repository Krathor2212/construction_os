import 'package:flutter_test/flutter_test.dart';

import 'package:construction_os/features/materials/data/repositories/mock_material_delivery_repository.dart';
import 'package:construction_os/features/materials/domain/entities/material_delivery.dart';

void main() {
  test('returns project deliveries newest first', () async {
    final repository = MockMaterialDeliveryRepository();

    final deliveries = await repository.getDeliveries(projectId: 'project-001');

    expect(deliveries, hasLength(1));
    expect(deliveries.first.status, MaterialDeliveryStatus.received);
  });

  test('updates a delivery status', () async {
    final repository = MockMaterialDeliveryRepository();
    final deliveries = await repository.getDeliveries(projectId: 'project-001');
    final original = deliveries.first;

    final updated = await repository.updateDelivery(
      MaterialDelivery(
        id: original.id,
        projectId: original.projectId,
        materialRequirementId: original.materialRequirementId,
        materialId: original.materialId,
        quantity: original.quantity,
        unit: original.unit,
        deliveryDate: original.deliveryDate,
        supplierName: original.supplierName,
        referenceNumber: original.referenceNumber,
        status: MaterialDeliveryStatus.partiallyReceived,
        notes: original.notes,
      ),
    );

    expect(updated.status, MaterialDeliveryStatus.partiallyReceived);
  });
}
