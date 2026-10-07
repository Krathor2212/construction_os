import '../entities/project_task_progress_update.dart';

abstract interface class ProjectTaskProgressRepository {
  Future<List<ProjectTaskProgressUpdate>> getUpdates(String taskId);

  Future<ProjectTaskProgressUpdate> createUpdate(
    ProjectTaskProgressUpdate update,
  );
}
