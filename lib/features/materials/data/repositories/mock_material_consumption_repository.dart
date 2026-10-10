import '../../domain/entities/material_consumption.dart';
import '../../domain/repositories/material_consumption_repository.dart';

class MockMaterialConsumptionRepository
    implements MaterialConsumptionRepository {
  final List<MaterialConsumption> _consumptions = [
    MaterialConsumption(
      id: 'consumption-001',
      projectId: 'project-001',
      materialId: 'material-001',
      phaseId: 'phase-001',
      quantity: 40,
      unit: 'bag',
      consumedDate: DateTime(2026, 10, 2),
      issuedTo: 'Foundation crew',
      notes: 'Foundation concrete pour.',
    ),
  ];

  @override
  Future<List<MaterialConsumption>> getConsumptions({
    required String projectId,
  }) async {
    return _consumptions
        .where((consumption) => consumption.projectId == projectId)
        .toList()
      ..sort((a, b) => b.consumedDate.compareTo(a.consumedDate));
  }

  @override
  Future<MaterialConsumption> createConsumption(
    MaterialConsumption consumption,
  ) async {
    _consumptions.add(consumption);
    return consumption;
  }
}
