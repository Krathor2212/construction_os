class DailySiteReport {
  const DailySiteReport({
    required this.id,
    required this.projectId,
    required this.date,
    required this.workCompleted,
    required this.workPlannedForNextDay,
    required this.issuesAndDelays,
    required this.safetyNotes,
    required this.qualityNotes,
    this.phaseId,
    this.generalNotes,
  });

  final String id;
  final String projectId;
  final String? phaseId;
  final DateTime date;

  final String workCompleted;
  final String workPlannedForNextDay;

  final String issuesAndDelays;
  final String safetyNotes;
  final String qualityNotes;

  final String? generalNotes;
}