import '../../domain/entities/material_requirement_procurement.dart';
import '../../domain/repositories/material_requirement_procurement_repository.dart';

class MockMaterialRequirementProcurementRepository
    implements MaterialRequirementProcurementRepository {
  final List<MaterialRequirementProcurement> _procurements = [
    MaterialRequirementProcurement(
      id: 'requirement-procurement-001',
      materialRequirementId: 'material-requirement-001',
      purchaseOrderId: 'purchase-order-002',
      quantity: 300,
      notes: 'Initial cement procurement.',
    ),
    MaterialRequirementProcurement(
      id: 'requirement-procurement-002',
      materialRequirementId: 'material-requirement-002',
      purchaseOrderId: 'purchase-order-001',
      quantity: 1500,
      notes: 'TMT steel ordered for structural work.',
    ),
  ];

  @override
  Future<List<MaterialRequirementProcurement>> getProcurements(
    String materialRequirementId,
  ) async {
    return _procurements
        .where(
          (procurement) =>
              procurement.materialRequirementId == materialRequirementId,
        )
        .toList();
  }

  @override
  Future<MaterialRequirementProcurement> createProcurement(
    MaterialRequirementProcurement procurement,
  ) async {
    _procurements.add(procurement);
    return procurement;
  }

  @override
  Future<MaterialRequirementProcurement> updateProcurement(
    MaterialRequirementProcurement procurement,
  ) async {
    final index = _procurements.indexWhere(
      (existing) => existing.id == procurement.id,
    );

    if (index == -1) {
      throw StateError('Procurement record not found.');
    }

    _procurements[index] = procurement;
    return procurement;
  }

  @override
  Future<void> deleteProcurement(String id) async {
    final index = _procurements.indexWhere(
      (procurement) => procurement.id == id,
    );

    if (index == -1) {
      throw StateError('Procurement record not found.');
    }

    _procurements.removeAt(index);
  }
}