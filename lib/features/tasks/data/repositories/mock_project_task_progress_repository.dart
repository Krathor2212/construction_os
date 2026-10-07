import '../../domain/entities/project_task.dart';
import '../../domain/entities/project_task_progress_update.dart';
import '../../domain/repositories/project_task_progress_repository.dart';

class MockProjectTaskProgressRepository
    implements ProjectTaskProgressRepository {
  MockProjectTaskProgressRepository()
      : _updates = [
          ProjectTaskProgressUpdate(
            id: 'task-progress-001',
            taskId: 'task-001',
            progress: 20,
            status: ProjectTaskStatus.inProgress,
            recordedAt: DateTime(2026, 9, 22, 17),
            notes: 'Excavation started.',
          ),
          ProjectTaskProgressUpdate(
            id: 'task-progress-002',
            taskId: 'task-001',
            progress: 45,
            status: ProjectTaskStatus.inProgress,
            recordedAt: DateTime(2026, 9, 23, 17),
            notes: 'Excavation progressing as planned.',
          ),
        ];

  final List<ProjectTaskProgressUpdate> _updates;

  @override
  Future<List<ProjectTaskProgressUpdate>> getUpdates(String taskId) async {
    final updates = _updates
        .where((update) => update.taskId == taskId)
        .toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));

    return List.unmodifiable(updates);
  }

  @override
  Future<ProjectTaskProgressUpdate> createUpdate(
    ProjectTaskProgressUpdate update,
  ) async {
    _updates.add(update);
    return update;
  }
}
