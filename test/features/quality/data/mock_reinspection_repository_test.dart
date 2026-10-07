import 'package:flutter_test/flutter_test.dart';

import 'package:construction_os/features/quality/data/repositories/mock_reinspection_repository.dart';
import 'package:construction_os/features/quality/domain/entities/reinspection.dart';

void main() {
  test('returns project reinspections newest first', () async {
    final repository = MockReinspectionRepository();

    final reinspections =
        await repository.getReinspections(projectId: 'project-001');

    expect(reinspections, hasLength(1));
    expect(reinspections.first.correctiveActionId, 'action-001');
    expect(reinspections.first.result, ReinspectionResult.passed);
  });

  test('stores a new reinspection for its corrective action', () async {
    final repository = MockReinspectionRepository();
    final reinspection = Reinspection(
      id: 'reinspection-002',
      projectId: 'project-001',
      phaseId: 'phase-001',
      correctiveActionId: 'action-001',
      originalInspectionResult: 'Failed',
      date: DateTime(2026, 10, 4),
      inspectorName: 'Ravi Kumar',
      result: ReinspectionResult.requiresAttention,
      notes: 'One small edge still needs correction.',
    );

    await repository.createReinspection(reinspection);
    final reinspections =
        await repository.getReinspections(projectId: 'project-001');

    expect(reinspections, hasLength(2));
    expect(reinspections.first.id, 'reinspection-002');
  });
}
