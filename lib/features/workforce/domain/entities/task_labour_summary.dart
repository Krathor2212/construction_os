class TaskLabourSummary {
  const TaskLabourSummary({
    required this.attendanceRecordCount,
    required this.totalHoursWorked,
    required this.totalOvertimeHours,
    required this.baseLabourCost,
    required this.overtimeCost,
    required this.totalLabourCost,
  });

  final int attendanceRecordCount;
  final double totalHoursWorked;
  final double totalOvertimeHours;
  final double baseLabourCost;
  final double overtimeCost;
  final double totalLabourCost;
}
