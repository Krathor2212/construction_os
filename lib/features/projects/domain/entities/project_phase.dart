class ProjectPhase {
  const ProjectPhase({
    required this.id,
    required this.projectId,
    required this.name,
    required this.plannedStartDate,
    required this.plannedEndDate,
    required this.status,
    this.actualStartDate,
    this.actualEndDate,
    this.progress = 0,
    this.notes,
    this.isArchived = false,
  });

  final String id;
  final String projectId;
  final String name;

  final DateTime plannedStartDate;
  final DateTime plannedEndDate;

  final DateTime? actualStartDate;
  final DateTime? actualEndDate;

  final ProjectPhaseStatus status;

  /// Progress from 0 to 100.
  final double progress;

  final String? notes;

  /// Archived phases are retained for project history
  /// but excluded from the active timeline.
  final bool isArchived;
}

enum ProjectPhaseStatus {
  notStarted,
  inProgress,
  completed,
  delayed,
  onHold,
}