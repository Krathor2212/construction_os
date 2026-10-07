import 'package:flutter_test/flutter_test.dart';

import 'package:construction_os/features/quality/data/repositories/mock_inspection_repository.dart';
import 'package:construction_os/features/quality/domain/entities/inspection.dart';

void main() {
  test('returns project inspections newest first', () async {
    final repository = MockInspectionRepository();

    final inspections = await repository.getInspections(
      projectId: 'project-001',
    );

    expect(inspections, hasLength(1));
    expect(inspections.first.result, InspectionResult.passed);
    expect(inspections.first.taskId, 'task-001');
  });

  test('stores a new inspection', () async {
    final repository = MockInspectionRepository();
    final inspection = Inspection(
      id: 'inspection-002',
      projectId: 'project-001',
      phaseId: 'phase-001',
      date: DateTime(2026, 9, 25),
      inspectorName: 'Project Manager',
      result: InspectionResult.requiresAttention,
      notes: 'Review edge protection before the next shift.',
    );

    await repository.createInspection(inspection);

    final inspections = await repository.getInspections(
      projectId: 'project-001',
    );
    expect(inspections.first.id, 'inspection-002');
  });
}
