import '../../domain/entities/reinspection.dart';
import '../../domain/repositories/reinspection_repository.dart';

class MockReinspectionRepository implements ReinspectionRepository {
  final List<Reinspection> _reinspections = [
    Reinspection(
      id: 'reinspection-001',
      projectId: 'project-001',
      phaseId: 'phase-001',
      taskId: 'task-001',
      correctiveActionId: 'action-001',
      originalInspectionResult: 'Requires attention',
      date: DateTime(2026, 10, 3),
      inspectorName: 'Maya Patel',
      result: ReinspectionResult.passed,
      notes: 'Excavation edge was corrected and is ready for the next activity.',
    ),
  ];

  @override
  Future<List<Reinspection>> getReinspections({
    required String projectId,
  }) async {
    return _reinspections
        .where((reinspection) => reinspection.projectId == projectId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<Reinspection> createReinspection(
    Reinspection reinspection,
  ) async {
    _reinspections.add(reinspection);
    return reinspection;
  }
}
