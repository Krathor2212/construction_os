import '../../domain/entities/material_delivery.dart';
import '../../domain/repositories/material_delivery_repository.dart';

class MockMaterialDeliveryRepository implements MaterialDeliveryRepository {
  final List<MaterialDelivery> _deliveries = [
    MaterialDelivery(
      id: 'delivery-001',
      projectId: 'project-001',
      materialRequirementId: 'material-requirement-001',
      materialId: 'material-001',
      quantity: 250,
      unit: 'bag',
      deliveryDate: DateTime(2026, 9, 28),
      supplierName: 'BuildMart Suppliers',
      referenceNumber: 'GRN-1001',
      status: MaterialDeliveryStatus.received,
      notes: 'First cement delivery for foundation work.',
    ),
  ];

  @override
  Future<List<MaterialDelivery>> getDeliveries({
    required String projectId,
  }) async {
    return _deliveries.where((delivery) => delivery.projectId == projectId).toList()
      ..sort((a, b) => b.deliveryDate.compareTo(a.deliveryDate));
  }

  @override
  Future<MaterialDelivery> createDelivery(MaterialDelivery delivery) async {
    _deliveries.add(delivery);
    return delivery;
  }

  @override
  Future<MaterialDelivery> updateDelivery(MaterialDelivery delivery) async {
    final index = _deliveries.indexWhere((item) => item.id == delivery.id);
    if (index == -1) {
      throw StateError('Material delivery ${delivery.id} not found.');
    }
    _deliveries[index] = delivery;
    return delivery;
  }
}
