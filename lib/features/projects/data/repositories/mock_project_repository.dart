import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';

class MockProjectRepository implements ProjectRepository {
  final List<Project> _projects = [
    Project(
      id: 'project-001',
      name: 'Residential Villa — Anna Nagar',
      clientId: 'client-001',
      siteAddress: 'Anna Nagar, Chennai',
      status: ProjectStatus.active,
      startDate: DateTime(2026, 8, 1),
      expectedEndDate: DateTime(2027, 2, 1),
      budget: 8500000,
    ),
    Project(
      id: 'project-002',
      name: 'Commercial Building — OMR',
      clientId: 'client-002',
      siteAddress: 'OMR, Chennai',
      status: ProjectStatus.planning,
      startDate: DateTime(2026, 10, 15),
      expectedEndDate: DateTime(2027, 8, 15),
      budget: 18500000,
    ),
  ];

  @override
  Future<List<Project>> getProjects() async {
    return List.unmodifiable(_projects);
  }

  @override
  Future<Project> getProject(String id) async {
    return _projects.firstWhere((project) => project.id == id);
  }

  @override
  Future<Project> createProject(Project project) async {
    _projects.add(project);
    return project;
  }

  @override
  Future<Project> updateProject(Project project) async {
    final index = _projects.indexWhere((item) => item.id == project.id);

    if (index == -1) {
      throw StateError('Project not found: ${project.id}');
    }

    _projects[index] = project;
    return project;
  }

  @override
  Future<void> deleteProject(String id) async {
    _projects.removeWhere((project) => project.id == id);
  }
}
