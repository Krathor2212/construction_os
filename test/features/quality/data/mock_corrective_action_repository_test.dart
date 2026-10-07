import 'package:flutter_test/flutter_test.dart';

import 'package:construction_os/features/quality/data/repositories/mock_corrective_action_repository.dart';
import 'package:construction_os/features/quality/domain/entities/corrective_action.dart';

void main() {
  test('returns project corrective actions newest first', () async {
    final repository = MockCorrectiveActionRepository();

    final actions = await repository.getActions(projectId: 'project-001');

    expect(actions, hasLength(1));
    expect(actions.first.title, 'Trim and compact excavation edge');
  });

  test('updates a corrective action status', () async {
    final repository = MockCorrectiveActionRepository();
    final actions = await repository.getActions(projectId: 'project-001');

    final updated = await repository.updateAction(
      CorrectiveAction(
        id: actions.first.id,
        projectId: actions.first.projectId,
        phaseId: actions.first.phaseId,
        taskId: actions.first.taskId,
        title: actions.first.title,
        description: actions.first.description,
        responsiblePerson: actions.first.responsiblePerson,
        dueDate: actions.first.dueDate,
        priority: actions.first.priority,
        status: CorrectiveActionStatus.completed,
        createdDate: actions.first.createdDate,
      ),
    );

    expect(updated.status, CorrectiveActionStatus.completed);
  });
}
