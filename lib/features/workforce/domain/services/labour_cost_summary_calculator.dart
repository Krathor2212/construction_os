import '../entities/labour_cost_summary.dart';
import '../entities/worker.dart';
import '../entities/worker_attendance.dart';
import 'labour_cost_calculator.dart';

class LabourCostSummaryCalculator {
  const LabourCostSummaryCalculator({
    this.labourCostCalculator = const LabourCostCalculator(),
  });

  final LabourCostCalculator labourCostCalculator;

  LabourCostSummary calculate({
    required List<Worker> workers,
    required List<WorkerAttendance> attendanceRecords,
  }) {
    var presentWorkers = 0;
    var halfDayWorkers = 0;
    var absentWorkers = 0;
    var leaveWorkers = 0;

    var baseLabourCost = 0.0;
    var overtimeCost = 0.0;

    final workersById = {
      for (final worker in workers) worker.id: worker,
    };

    for (final attendance in attendanceRecords) {
      final worker = workersById[attendance.workerId];

      if (worker == null) {
        continue;
      }

      switch (attendance.status) {
        case AttendanceStatus.present:
          presentWorkers++;
          break;

        case AttendanceStatus.halfDay:
          halfDayWorkers++;
          break;

        case AttendanceStatus.absent:
          absentWorkers++;
          break;

        case AttendanceStatus.leave:
          leaveWorkers++;
          break;
      }

      baseLabourCost += labourCostCalculator.calculateBaseCost(
        worker: worker,
        attendance: attendance,
      );

      overtimeCost += labourCostCalculator.calculateOvertimeCost(
        worker: worker,
        attendance: attendance,
      );
    }

    return LabourCostSummary(
      totalWorkers: attendanceRecords.length,
      presentWorkers: presentWorkers,
      halfDayWorkers: halfDayWorkers,
      absentWorkers: absentWorkers,
      leaveWorkers: leaveWorkers,
      baseLabourCost: baseLabourCost,
      overtimeCost: overtimeCost,
      totalLabourCost: baseLabourCost + overtimeCost,
    );
  }
}