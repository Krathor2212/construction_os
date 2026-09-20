class LabourPhaseCostSummary {
  const LabourPhaseCostSummary({
    required this.phaseId,
    required this.phaseName,
    required this.workerCount,
    required this.presentWorkers,
    required this.halfDayWorkers,
    required this.absentWorkers,
    required this.leaveWorkers,
    required this.baseLabourCost,
    required this.overtimeCost,
    required this.totalLabourCost,
  });

  final String phaseId;
  final String phaseName;

  final int workerCount;
  final int presentWorkers;
  final int halfDayWorkers;
  final int absentWorkers;
  final int leaveWorkers;

  final double baseLabourCost;
  final double overtimeCost;
  final double totalLabourCost;
}