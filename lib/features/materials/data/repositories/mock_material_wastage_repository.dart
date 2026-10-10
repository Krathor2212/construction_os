import '../../domain/entities/material_wastage.dart';
import '../../domain/repositories/material_wastage_repository.dart';

class MockMaterialWastageRepository implements MaterialWastageRepository {
  final List<MaterialWastage> _wastage = [
    MaterialWastage(
      id: 'wastage-001',
      projectId: 'project-001',
      materialId: 'material-001',
      quantity: 5,
      unit: 'bag',
      wastedDate: DateTime(2026, 10, 3),
      reason: MaterialWastageReason.damage,
      reportedBy: 'Site Supervisor',
      notes: 'Two damaged bags identified during storage inspection.',
    ),
  ];

  @override
  Future<List<MaterialWastage>> getWastage({required String projectId}) async {
    return _wastage.where((item) => item.projectId == projectId).toList()
      ..sort((a, b) => b.wastedDate.compareTo(a.wastedDate));
  }

  @override
  Future<MaterialWastage> createWastage(MaterialWastage wastage) async {
    _wastage.add(wastage);
    return wastage;
  }
}
