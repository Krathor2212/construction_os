enum PunchListPriority { low, medium, high, critical }

enum PunchListStatus { open, inProgress, completed }

class PunchListItem {
  const PunchListItem({
    required this.id,
    required this.projectId,
    required this.phaseId,
    required this.title,
    required this.description,
    required this.location,
    required this.priority,
    required this.status,
    required this.reportedDate,
    this.taskId,
  });

  final String id;
  final String projectId;
  final String phaseId;
  final String? taskId;
  final String title;
  final String description;
  final String location;
  final PunchListPriority priority;
  final PunchListStatus status;
  final DateTime reportedDate;
}
