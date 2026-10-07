import 'package:flutter_test/flutter_test.dart';

import 'package:construction_os/features/tasks/data/repositories/mock_project_task_progress_repository.dart';
import 'package:construction_os/features/tasks/domain/entities/project_task.dart';
import 'package:construction_os/features/tasks/domain/entities/project_task_progress_update.dart';

void main() {
  test('returns task progress updates newest first', () async {
    final repository = MockProjectTaskProgressRepository();

    final updates = await repository.getUpdates('task-001');

    expect(updates.map((update) => update.progress), [45, 20]);
  });

  test('stores a new progress update for its task', () async {
    final repository = MockProjectTaskProgressRepository();

    await repository.createUpdate(
      ProjectTaskProgressUpdate(
        id: 'task-progress-003',
        taskId: 'task-002',
        progress: 10,
        status: ProjectTaskStatus.inProgress,
        recordedAt: DateTime(2026, 9, 26),
      ),
    );

    final updates = await repository.getUpdates('task-002');
    expect(updates.single.progress, 10);
  });
}
