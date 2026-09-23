import '../../domain/entities/project_task.dart';
import '../../domain/repositories/project_task_repository.dart';

class MockProjectTaskRepository implements ProjectTaskRepository {
  MockProjectTaskRepository()
      : _tasks = [
          ProjectTask(
            id: 'task-001',
            projectId: 'project-001',
            phaseId: 'phase-001',
            name: 'Site excavation',
            description: 'Excavate foundation area as per approved layout.',
            plannedStartDate: DateTime(2026, 9, 22),
            plannedEndDate: DateTime(2026, 9, 24),
            actualStartDate: DateTime(2026, 9, 22),
            status: ProjectTaskStatus.inProgress,
            priority: ProjectTaskPriority.high,
            progress: 45,
            notes: 'Excavation progressing as planned.',
          ),
          ProjectTask(
            id: 'task-002',
            projectId: 'project-001',
            phaseId: 'phase-001',
            name: 'PCC work',
            description: 'Prepare and complete plain cement concrete work.',
            plannedStartDate: DateTime(2026, 9, 25),
            plannedEndDate: DateTime(2026, 9, 26),
            status: ProjectTaskStatus.notStarted,
            priority: ProjectTaskPriority.medium,
          ),
        ];

  final List<ProjectTask> _tasks;

  @override
  Future<List<ProjectTask>> getTasks({
    required String projectId,
  }) async {
    return _tasks
        .where(
          (task) =>
              task.projectId == projectId &&
              !task.isArchived,
        )
        .toList();
  }

  @override
  Future<ProjectTask> getTask(
    String id,
  ) async {
    return _tasks.firstWhere(
      (task) => task.id == id,
    );
  }

  @override
  Future<ProjectTask> createTask(
    ProjectTask task,
  ) async {
    _tasks.add(task);
    return task;
  }

  @override
  Future<ProjectTask> updateTask(
    ProjectTask task,
  ) async {
    final index = _tasks.indexWhere(
      (item) => item.id == task.id,
    );

    if (index == -1) {
      throw StateError(
        'Task not found: ${task.id}',
      );
    }

    _tasks[index] = task;
    return task;
  }

  @override
  Future<void> deleteTask(
    String id,
  ) async {
    final index = _tasks.indexWhere(
      (task) => task.id == id,
    );

    if (index == -1) {
      throw StateError(
        'Task not found: $id',
      );
    }

    _tasks.removeAt(index);
  }
}