import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_project_task_progress_repository.dart';
import '../../domain/entities/project_task_progress_update.dart';
import '../../domain/repositories/project_task_progress_repository.dart';

final projectTaskProgressRepositoryProvider =
    Provider<ProjectTaskProgressRepository>((ref) {
  return MockProjectTaskProgressRepository();
});

final projectTaskProgressProvider = FutureProvider.family<
    List<ProjectTaskProgressUpdate>, String>((ref, taskId) async {
  final repository = ref.watch(projectTaskProgressRepositoryProvider);
  return repository.getUpdates(taskId);
});

final projectTaskProgressActionsProvider =
    Provider<ProjectTaskProgressActions>((ref) {
  return ProjectTaskProgressActions(ref);
});

class ProjectTaskProgressActions {
  ProjectTaskProgressActions(this._ref);

  final Ref _ref;

  Future<ProjectTaskProgressUpdate> createUpdate(
    ProjectTaskProgressUpdate update,
  ) async {
    final repository = _ref.read(projectTaskProgressRepositoryProvider);
    final createdUpdate = await repository.createUpdate(update);
    _ref.invalidate(projectTaskProgressProvider(update.taskId));
    return createdUpdate;
  }
}
