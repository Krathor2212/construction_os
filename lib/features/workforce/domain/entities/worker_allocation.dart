class WorkerAllocation {
  const WorkerAllocation({
    required this.id,
    required this.workerId,
    required this.projectId,
    required this.date,
    required this.workDescription,
    required this.plannedHours,
    this.phaseId,
    this.notes,
  });

  final String id;
  final String workerId;
  final String projectId;
  final String? phaseId;
  final DateTime date;
  final String workDescription;
  final double plannedHours;
  final String? notes;
}