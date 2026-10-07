enum InspectionResult {
  passed,
  failed,
  requiresAttention,
}

class Inspection {
  const Inspection({
    required this.id,
    required this.projectId,
    required this.phaseId,
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
  final DateTime date;
  final String inspectorName;
  final InspectionResult result;
  final String notes;
}
