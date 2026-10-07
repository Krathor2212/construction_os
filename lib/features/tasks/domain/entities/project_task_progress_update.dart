import 'project_task.dart';

class ProjectTaskProgressUpdate {
  const ProjectTaskProgressUpdate({
    required this.id,
    required this.taskId,
    required this.progress,
    required this.status,
    required this.recordedAt,
    this.notes,
  });

  final String id;
  final String taskId;
  final double progress;
  final ProjectTaskStatus status;
  final DateTime recordedAt;
  final String? notes;
}
