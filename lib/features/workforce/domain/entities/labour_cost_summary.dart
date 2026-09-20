class LabourCostSummary {
  const LabourCostSummary({
    required this.totalWorkers,
    required this.presentWorkers,
    required this.halfDayWorkers,
    required this.absentWorkers,
    required this.leaveWorkers,
    required this.baseLabourCost,
    required this.overtimeCost,
    required this.totalLabourCost,
  });

  final int totalWorkers;
  final int presentWorkers;
  final int halfDayWorkers;
  final int absentWorkers;
  final int leaveWorkers;

  final double baseLabourCost;
  final double overtimeCost;
  final double totalLabourCost;
}