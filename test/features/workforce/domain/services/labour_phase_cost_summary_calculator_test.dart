import 'package:flutter_test/flutter_test.dart';

import 'package:construction_os/features/projects/domain/entities/project_phase.dart';
import 'package:construction_os/features/workforce/domain/entities/worker.dart';
import 'package:construction_os/features/workforce/domain/entities/worker_attendance.dart';
import 'package:construction_os/features/workforce/domain/services/labour_phase_cost_summary_calculator.dart';

void main() {
  const calculator = LabourPhaseCostSummaryCalculator();

  final foundationPhase = ProjectPhase(
    id: 'phase-001',
    projectId: 'project-001',
    name: 'Foundation',
    plannedStartDate: DateTime(2026, 9, 1),
    plannedEndDate: DateTime(2026, 9, 10),
    status: ProjectPhaseStatus.inProgress,
  );

  final structurePhase = ProjectPhase(
    id: 'phase-002',
    projectId: 'project-001',
    name: 'Structure',
    plannedStartDate: DateTime(2026, 9, 11),
    plannedEndDate: DateTime(2026, 9, 30),
    status: ProjectPhaseStatus.notStarted,
  );

  final workerOne = Worker(
    id: 'worker-001',
    name: 'Ramesh',
    role: WorkerRole.mason,
    phone: '9000000001',
    dailyWage: 900,
    overtimeRate: 150,
  );

  final workerTwo = Worker(
    id: 'worker-002',
    name: 'Suresh',
    role: WorkerRole.helper,
    phone: '9000000002',
    dailyWage: 800,
    overtimeRate: 100,
  );

  test('groups labour cost by phase', () {
    final attendance = [
      WorkerAttendance(
        id: 'attendance-001',
        workerId: 'worker-001',
        date: DateTime(2026, 9, 20),
        status: AttendanceStatus.present,
        projectId: 'project-001',
        phaseId: 'phase-001',
        hoursWorked: 8,
        overtimeHours: 2,
      ),
      WorkerAttendance(
        id: 'attendance-002',
        workerId: 'worker-002',
        date: DateTime(2026, 9, 20),
        status: AttendanceStatus.halfDay,
        projectId: 'project-001',
        phaseId: 'phase-001',
        hoursWorked: 4,
        overtimeHours: 0,
      ),
      WorkerAttendance(
        id: 'attendance-003',
        workerId: 'worker-002',
        date: DateTime(2026, 9, 20),
        status: AttendanceStatus.present,
        projectId: 'project-001',
        phaseId: 'phase-002',
        hoursWorked: 8,
        overtimeHours: 1,
      ),
    ];

    final result = calculator.calculate(
      phases: [
        foundationPhase,
        structurePhase,
      ],
      workers: [
        workerOne,
        workerTwo,
      ],
      attendanceRecords: attendance,
    );

    expect(result.length, 2);

    final foundation = result.firstWhere(
      (summary) => summary.phaseId == 'phase-001',
    );

    expect(foundation.phaseName, 'Foundation');
    expect(foundation.workerCount, 2);
    expect(foundation.presentWorkers, 1);
    expect(foundation.halfDayWorkers, 1);
    expect(foundation.baseLabourCost, 1300);
    expect(foundation.overtimeCost, 300);
    expect(foundation.totalLabourCost, 1600);

    final structure = result.firstWhere(
      (summary) => summary.phaseId == 'phase-002',
    );

    expect(structure.phaseName, 'Structure');
    expect(structure.workerCount, 1);
    expect(structure.presentWorkers, 1);
    expect(structure.baseLabourCost, 800);
    expect(structure.overtimeCost, 100);
    expect(structure.totalLabourCost, 900);
  });

  test('ignores attendance without a phase', () {
    final attendance = [
      WorkerAttendance(
        id: 'attendance-001',
        workerId: 'worker-001',
        date: DateTime(2026, 9, 20),
        status: AttendanceStatus.present,
        projectId: 'project-001',
        phaseId: null,
        hoursWorked: 8,
        overtimeHours: 0,
      ),
    ];

    final result = calculator.calculate(
      phases: [foundationPhase],
      workers: [workerOne],
      attendanceRecords: attendance,
    );

    expect(result, isEmpty);
  });

  test('ignores attendance linked to an unknown phase', () {
    final attendance = [
      WorkerAttendance(
        id: 'attendance-001',
        workerId: 'worker-001',
        date: DateTime(2026, 9, 20),
        status: AttendanceStatus.present,
        projectId: 'project-001',
        phaseId: 'phase-does-not-exist',
        hoursWorked: 8,
        overtimeHours: 0,
      ),
    ];

    final result = calculator.calculate(
      phases: [foundationPhase],
      workers: [workerOne],
      attendanceRecords: attendance,
    );

    expect(result, isEmpty);
  });

  test('ignores attendance linked to an unknown worker', () {
    final attendance = [
      WorkerAttendance(
        id: 'attendance-001',
        workerId: 'worker-does-not-exist',
        date: DateTime(2026, 9, 20),
        status: AttendanceStatus.present,
        projectId: 'project-001',
        phaseId: 'phase-001',
        hoursWorked: 8,
        overtimeHours: 0,
      ),
    ];

    final result = calculator.calculate(
      phases: [foundationPhase],
      workers: [workerOne],
      attendanceRecords: attendance,
    );

    expect(result, isEmpty);
  });
}