class TaskExecutionComparison {
  const TaskExecutionComparison({
    required this.plannedDurationDays,
    required this.actualDurationDays,
    required this.varianceDays,
    required this.isOverdue,
    required this.varianceLabel,
  });

  final int plannedDurationDays;
  final int? actualDurationDays;
  final int? varianceDays;
  final bool isOverdue;
  final String varianceLabel;
}
