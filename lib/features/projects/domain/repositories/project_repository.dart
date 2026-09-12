import '../entities/project.dart';

abstract interface class ProjectRepository {
  Future<List<Project>> getProjects();

  Future<Project> getProject(String id);

  Future<Project> createProject(Project project);

  Future<Project> updateProject(Project project);

  Future<void> deleteProject(String id);
}
