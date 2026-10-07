enum CorrectiveActionPriority { low, medium, high, critical }

enum CorrectiveActionStatus { open, inProgress, completed }

class CorrectiveAction {
  const CorrectiveAction({
    required this.id,
    required this.projectId,
    required this.phaseId,
    required this.title,
    required this.description,
    required this.responsiblePerson,
    required this.dueDate,
    required this.priority,
    required this.status,
    required this.createdDate,
    this.taskId,
  });

  final String id;
  final String projectId;
  final String phaseId;
  final String? taskId;
  final String title;
  final String description;
  final String responsiblePerson;
  final DateTime dueDate;
  final CorrectiveActionPriority priority;
  final CorrectiveActionStatus status;
  final DateTime createdDate;
}
