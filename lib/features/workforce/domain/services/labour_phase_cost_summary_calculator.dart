import '../../../projects/domain/entities/project_phase.dart';
import '../entities/labour_phase_cost_summary.dart';
import '../entities/worker.dart';
import '../entities/worker_attendance.dart';
import 'labour_cost_calculator.dart';

class LabourPhaseCostSummaryCalculator {
  const LabourPhaseCostSummaryCalculator({
    this.labourCostCalculator = const LabourCostCalculator(),
  });

  final LabourCostCalculator labourCostCalculator;

  List<LabourPhaseCostSummary> calculate({
    required List<ProjectPhase> phases,
    required List<Worker> workers,
    required List<WorkerAttendance> attendanceRecords,
  }) {
    final workersById = {
      for (final worker in workers) worker.id: worker,
    };

    final phasesById = {
      for (final phase in phases) phase.id: phase,
    };

    final attendanceByPhase = <String, List<WorkerAttendance>>{};

    for (final attendance in attendanceRecords) {
      final phaseId = attendance.phaseId;

      if (phaseId == null) {
        continue;
      }

      if (!phasesById.containsKey(phaseId)) {
        continue;
      }

      if (!workersById.containsKey(attendance.workerId)) {
        continue;
      }

      attendanceByPhase.putIfAbsent(
        phaseId,
        () => <WorkerAttendance>[],
      ).add(attendance);
    }

    final summaries = <LabourPhaseCostSummary>[];

    for (final entry in attendanceByPhase.entries) {
      final phaseId = entry.key;
      final records = entry.value;
      final phase = phasesById[phaseId]!;

      var presentWorkers = 0;
      var halfDayWorkers = 0;
      var absentWorkers = 0;
      var leaveWorkers = 0;

      var baseLabourCost = 0.0;
      var overtimeCost = 0.0;

      final workerIds = <String>{};

      for (final attendance in records) {
        final worker = workersById[attendance.workerId]!;

        workerIds.add(worker.id);

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

      summaries.add(
        LabourPhaseCostSummary(
          phaseId: phase.id,
          phaseName: phase.name,
          workerCount: workerIds.length,
          presentWorkers: presentWorkers,
          halfDayWorkers: halfDayWorkers,
          absentWorkers: absentWorkers,
          leaveWorkers: leaveWorkers,
          baseLabourCost: baseLabourCost,
          overtimeCost: overtimeCost,
          totalLabourCost: baseLabourCost + overtimeCost,
        ),
      );
    }

    summaries.sort(
      (a, b) => a.phaseName.toLowerCase().compareTo(
            b.phaseName.toLowerCase(),
          ),
    );

    return summaries;
  }
}