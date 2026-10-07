enum DefectSeverity {
  low,
  medium,
  high,
  critical,
}

enum DefectStatus {
  open,
  inProgress,
  resolved,
}

class Defect {
  const Defect({
    required this.id,
    required this.projectId,
    required this.phaseId,
    required this.title,
    required this.description,
    required this.location,
    required this.reportedDate,
    required this.severity,
    required this.status,
    this.taskId,
  });

  final String id;
  final String projectId;
  final String phaseId;
  final String? taskId;
  final String title;
  final String description;
  final String location;
  final DateTime reportedDate;
  final DefectSeverity severity;
  final DefectStatus status;
}
