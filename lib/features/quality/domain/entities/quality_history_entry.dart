enum QualityHistoryType {
  inspection,
  defect,
  punchList,
  correctiveAction,
  reinspection,
}

class QualityHistoryEntry {
  const QualityHistoryEntry({
    required this.id,
    required this.projectId,
    required this.type,
    required this.date,
    required this.title,
    required this.summary,
    required this.status,
  });

  final String id;
  final String projectId;
  final QualityHistoryType type;
  final DateTime date;
  final String title;
  final String summary;
  final String status;
}
