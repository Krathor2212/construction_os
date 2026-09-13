import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_project_repository.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return MockProjectRepository();
});

final projectsProvider = FutureProvider<List<Project>>((ref) async {
  final repository = ref.watch(projectRepositoryProvider);

  return repository.getProjects();
});

final projectProvider = FutureProvider.family<Project, String>(
  (ref, projectId) async {
    final repository = ref.watch(projectRepositoryProvider);

    return repository.getProject(projectId);
  },
);
