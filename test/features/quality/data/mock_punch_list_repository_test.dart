import 'package:flutter_test/flutter_test.dart';

import 'package:construction_os/features/quality/data/repositories/mock_punch_list_repository.dart';
import 'package:construction_os/features/quality/domain/entities/punch_list_item.dart';

void main() {
  test('returns project punch-list items', () async {
    final repository = MockPunchListRepository();
    final items = await repository.getItems(projectId: 'project-001');

    expect(items, hasLength(1));
    expect(items.first.priority, PunchListPriority.high);
    expect(items.first.status, PunchListStatus.open);
  });

  test('updates a punch-list item status', () async {
    final repository = MockPunchListRepository();
    final original = (await repository.getItems(projectId: 'project-001')).first;

    await repository.updateItem(PunchListItem(
      id: original.id,
      projectId: original.projectId,
      phaseId: original.phaseId,
      taskId: original.taskId,
      title: original.title,
      description: original.description,
      location: original.location,
      priority: original.priority,
      status: PunchListStatus.completed,
      reportedDate: original.reportedDate,
    ));

    expect(
      (await repository.getItems(projectId: 'project-001')).first.status,
      PunchListStatus.completed,
    );
  });
}
