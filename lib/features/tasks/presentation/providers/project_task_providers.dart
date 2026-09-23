import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_project_task_repository.dart';
import '../../domain/entities/project_task.dart';
import '../../domain/repositories/project_task_repository.dart';

final projectTaskRepositoryProvider =
    Provider<ProjectTaskRepository>((ref) {
  return MockProjectTaskRepository();
});

final projectTasksProvider =
    FutureProvider.family<List<ProjectTask>, String>(
  (ref, projectId) async {
    final repository = ref.watch(
      projectTaskRepositoryProvider,
    );

    return repository.getTasks(
      projectId: projectId,
    );
  },
);

final projectTaskProvider =
    FutureProvider.family<ProjectTask, String>(
  (ref, taskId) async {
    final repository = ref.watch(
      projectTaskRepositoryProvider,
    );

    return repository.getTask(taskId);
  },
);

final projectTaskActionsProvider =
    Provider<ProjectTaskActions>((ref) {
  return ProjectTaskActions(ref);
});

class ProjectTaskActions {
  ProjectTaskActions(this._ref);

  final Ref _ref;

  Future<ProjectTask> createTask(
    ProjectTask task,
  ) async {
    final repository = _ref.read(
      projectTaskRepositoryProvider,
    );

    final createdTask = await repository.createTask(
      task,
    );

    _ref.invalidate(
      projectTasksProvider(task.projectId),
    );

    return createdTask;
  }

  Future<ProjectTask> updateTask(
    ProjectTask task,
  ) async {
    final repository = _ref.read(
      projectTaskRepositoryProvider,
    );

    final updatedTask = await repository.updateTask(
      task,
    );

    _ref.invalidate(
      projectTasksProvider(task.projectId),
    );

    _ref.invalidate(
      projectTaskProvider(task.id),
    );

    return updatedTask;
  }

  Future<void> archiveTask(
    ProjectTask task,
  ) async {
    final repository = _ref.read(
      projectTaskRepositoryProvider,
    );

    final archivedTask = ProjectTask(
      id: task.id,
      projectId: task.projectId,
      phaseId: task.phaseId,
      name: task.name,
      description: task.description,
      plannedStartDate: task.plannedStartDate,
      plannedEndDate: task.plannedEndDate,
      actualStartDate: task.actualStartDate,
      actualEndDate: task.actualEndDate,
      status: task.status,
      priority: task.priority,
      progress: task.progress,
      notes: task.notes,
      isArchived: true,
    );

    await repository.updateTask(
      archivedTask,
    );

    _ref.invalidate(
      projectTasksProvider(task.projectId),
    );
  }
}