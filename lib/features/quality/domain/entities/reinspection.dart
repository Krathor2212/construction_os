enum ReinspectionResult { passed, failed, requiresAttention }

class Reinspection {
  const Reinspection({
    required this.id,
    required this.projectId,
    required this.phaseId,
    required this.correctiveActionId,
    required this.originalInspectionResult,
    required this.date,
    required this.inspectorName,
    required this.result,
    required this.notes,
    this.taskId,
  });

  final String id;
  final String projectId;
  final String phaseId;
  final String? taskId;
  final String correctiveActionId;
  final String originalInspectionResult;
  final DateTime date;
  final String inspectorName;
  final ReinspectionResult result;
  final String notes;
}
