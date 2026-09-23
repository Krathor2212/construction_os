enum ProjectTaskStatus {
  notStarted,
  inProgress,
  completed,
  delayed,
  onHold,
}

enum ProjectTaskPriority {
  low,
  medium,
  high,
  critical,
}

class ProjectTask {
  const ProjectTask({
    required this.id,
    required this.projectId,
    required this.phaseId,
    required this.name,
    required this.plannedStartDate,
    required this.plannedEndDate,
    required this.status,
    required this.priority,
    this.description,
    this.actualStartDate,
    this.actualEndDate,
    this.progress = 0,
    this.notes,
    this.isArchived = false,
  });

  final String id;
  final String projectId;
  final String phaseId;

  final String name;
  final String? description;

  final DateTime plannedStartDate;
  final DateTime plannedEndDate;

  final DateTime? actualStartDate;
  final DateTime? actualEndDate;

  final ProjectTaskStatus status;
  final ProjectTaskPriority priority;

  final double progress;

  final String? notes;
  final bool isArchived;
}