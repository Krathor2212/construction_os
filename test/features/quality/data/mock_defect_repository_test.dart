import 'package:flutter_test/flutter_test.dart';

import 'package:construction_os/features/quality/data/repositories/mock_defect_repository.dart';
import 'package:construction_os/features/quality/domain/entities/defect.dart';

void main() {
  test('returns project defects newest first', () async {
    final repository = MockDefectRepository();

    final defects = await repository.getDefects(projectId: 'project-001');

    expect(defects, hasLength(1));
    expect(defects.first.severity, DefectSeverity.medium);
    expect(defects.first.status, DefectStatus.open);
  });

  test('updates a defect status', () async {
    final repository = MockDefectRepository();
    final original = (await repository.getDefects(projectId: 'project-001')).first;

    await repository.updateDefect(
      Defect(
        id: original.id,
        projectId: original.projectId,
        phaseId: original.phaseId,
        taskId: original.taskId,
        title: original.title,
        description: original.description,
        location: original.location,
        reportedDate: original.reportedDate,
        severity: original.severity,
        status: DefectStatus.resolved,
      ),
    );

    final defects = await repository.getDefects(projectId: 'project-001');
    expect(defects.first.status, DefectStatus.resolved);
  });
}
