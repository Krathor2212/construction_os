import '../../domain/entities/inspection.dart';
import '../../domain/repositories/inspection_repository.dart';

class MockInspectionRepository implements InspectionRepository {
  final List<Inspection> _inspections = [
    Inspection(
      id: 'inspection-001',
      projectId: 'project-001',
      phaseId: 'phase-001',
      taskId: 'task-001',
      date: DateTime(2026, 9, 24),
      inspectorName: 'Site Engineer',
      result: InspectionResult.passed,
      notes: 'Excavation depth and formation level verified.',
    ),
  ];

  @override
  Future<List<Inspection>> getInspections({required String projectId}) async {
    return _inspections
        .where((inspection) => inspection.projectId == projectId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<Inspection> createInspection(Inspection inspection) async {
    _inspections.add(inspection);
    return inspection;
  }
}
