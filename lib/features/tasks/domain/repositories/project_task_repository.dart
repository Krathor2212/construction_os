import '../entities/project_task.dart';

abstract interface class ProjectTaskRepository {
  Future<List<ProjectTask>> getTasks({
    required String projectId,
  });

  Future<ProjectTask> getTask(
    String id,
  );

  Future<ProjectTask> createTask(
    ProjectTask task,
  );

  Future<ProjectTask> updateTask(
    ProjectTask task,
  );

  Future<void> deleteTask(
    String id,
  );
}