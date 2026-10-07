import '../entities/task_labour_summary.dart';
import '../entities/worker.dart';
import '../entities/worker_attendance.dart';
import 'labour_cost_calculator.dart';

class TaskLabourCalculator {
  const TaskLabourCalculator({
    this.labourCostCalculator = const LabourCostCalculator(),
  });

  final LabourCostCalculator labourCostCalculator;

  TaskLabourSummary calculate({
    required List<Worker> assignedWorkers,
    required List<WorkerAttendance> attendanceRecords,
  }) {
    final workersById = {
      for (final worker in assignedWorkers) worker.id: worker,
    };

    var totalHoursWorked = 0.0;
    var totalOvertimeHours = 0.0;
    var baseLabourCost = 0.0;
    var overtimeCost = 0.0;
    var matchedRecords = 0;

    for (final attendance in attendanceRecords) {
      final worker = workersById[attendance.workerId];
      if (worker == null) {
        continue;
      }

      matchedRecords++;
      totalHoursWorked += attendance.hoursWorked;
      totalOvertimeHours += attendance.overtimeHours;
      baseLabourCost += labourCostCalculator.calculateBaseCost(
        worker: worker,
        attendance: attendance,
      );
      overtimeCost += labourCostCalculator.calculateOvertimeCost(
        worker: worker,
        attendance: attendance,
      );
    }

    return TaskLabourSummary(
      attendanceRecordCount: matchedRecords,
      totalHoursWorked: totalHoursWorked,
      totalOvertimeHours: totalOvertimeHours,
      baseLabourCost: baseLabourCost,
      overtimeCost: overtimeCost,
      totalLabourCost: baseLabourCost + overtimeCost,
    );
  }
}
