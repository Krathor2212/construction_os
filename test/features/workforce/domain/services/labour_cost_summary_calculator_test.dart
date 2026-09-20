import 'package:flutter_test/flutter_test.dart';

import 'package:construction_os/features/workforce/domain/entities/worker.dart';
import 'package:construction_os/features/workforce/domain/entities/worker_attendance.dart';
import 'package:construction_os/features/workforce/domain/services/labour_cost_summary_calculator.dart';

void main() {
  const calculator = LabourCostSummaryCalculator();

  final workers = [
    const Worker(
      id: 'worker-1',
      name: 'Ramesh',
      role: WorkerRole.mason,
      phone: '9000000001',
      dailyWage: 900,
      overtimeRate: 150,
    ),
    const Worker(
      id: 'worker-2',
      name: 'Suresh',
      role: WorkerRole.helper,
      phone: '9000000002',
      dailyWage: 700,
      overtimeRate: 100,
    ),
    const Worker(
      id: 'worker-3',
      name: 'Manoj',
      role: WorkerRole.carpenter,
      phone: '9000000003',
      dailyWage: 1000,
      overtimeRate: 175,
    ),
    const Worker(
      id: 'worker-4',
      name: 'Karthik',
      role: WorkerRole.electrician,
      phone: '9000000004',
      dailyWage: 1200,
      overtimeRate: 200,
    ),
  ];

  test('calculates worker counts correctly', () {
    final attendanceRecords = [
      WorkerAttendance(
        id: 'attendance-1',
        workerId: 'worker-1',
        projectId: 'project-1',
        date: DateTime(2026, 9, 20),
        status: AttendanceStatus.present,
        hoursWorked: 8,
        overtimeHours: 2,
      ),
      WorkerAttendance(
        id: 'attendance-2',
        workerId: 'worker-2',
        projectId: 'project-1',
        date: DateTime(2026, 9, 20),
        status: AttendanceStatus.halfDay,
        hoursWorked: 4,
        overtimeHours: 0,
      ),
      WorkerAttendance(
        id: 'attendance-3',
        workerId: 'worker-3',
        projectId: 'project-1',
        date: DateTime(2026, 9, 20),
        status: AttendanceStatus.absent,
        hoursWorked: 0,
        overtimeHours: 0,
      ),
      WorkerAttendance(
        id: 'attendance-4',
        workerId: 'worker-4',
        projectId: 'project-1',
        date: DateTime(2026, 9, 20),
        status: AttendanceStatus.leave,
        hoursWorked: 0,
        overtimeHours: 0,
      ),
    ];

    final summary = calculator.calculate(
      workers: workers,
      attendanceRecords: attendanceRecords,
    );

    expect(summary.totalWorkers, 4);
    expect(summary.presentWorkers, 1);
    expect(summary.halfDayWorkers, 1);
    expect(summary.absentWorkers, 1);
    expect(summary.leaveWorkers, 1);
  });

  test('calculates base labour cost correctly', () {
    final attendanceRecords = [
      WorkerAttendance(
        id: 'attendance-1',
        workerId: 'worker-1',
        projectId: 'project-1',
        date: DateTime(2026, 9, 20),
        status: AttendanceStatus.present,
        hoursWorked: 8,
        overtimeHours: 0,
      ),
      WorkerAttendance(
        id: 'attendance-2',
        workerId: 'worker-2',
        projectId: 'project-1',
        date: DateTime(2026, 9, 20),
        status: AttendanceStatus.halfDay,
        hoursWorked: 4,
        overtimeHours: 0,
      ),
    ];

    final summary = calculator.calculate(
      workers: workers,
      attendanceRecords: attendanceRecords,
    );

    // Ramesh = ₹900
    // Suresh half-day = ₹350
    expect(summary.baseLabourCost, 1250);
  });

  test('calculates overtime cost correctly', () {
    final attendanceRecords = [
      WorkerAttendance(
        id: 'attendance-1',
        workerId: 'worker-1',
        projectId: 'project-1',
        date: DateTime(2026, 9, 20),
        status: AttendanceStatus.present,
        hoursWorked: 8,
        overtimeHours: 2,
      ),
      WorkerAttendance(
        id: 'attendance-2',
        workerId: 'worker-2',
        projectId: 'project-1',
        date: DateTime(2026, 9, 20),
        status: AttendanceStatus.present,
        hoursWorked: 8,
        overtimeHours: 3,
      ),
    ];

    final summary = calculator.calculate(
      workers: workers,
      attendanceRecords: attendanceRecords,
    );

    // Ramesh = 2 × ₹150 = ₹300
    // Suresh = 3 × ₹100 = ₹300
    expect(summary.overtimeCost, 600);
  });

  test('calculates total labour cost correctly', () {
    final attendanceRecords = [
      WorkerAttendance(
        id: 'attendance-1',
        workerId: 'worker-1',
        projectId: 'project-1',
        date: DateTime(2026, 9, 20),
        status: AttendanceStatus.present,
        hoursWorked: 8,
        overtimeHours: 2,
      ),
      WorkerAttendance(
        id: 'attendance-2',
        workerId: 'worker-2',
        projectId: 'project-1',
        date: DateTime(2026, 9, 20),
        status: AttendanceStatus.halfDay,
        hoursWorked: 4,
        overtimeHours: 2,
      ),
    ];

    final summary = calculator.calculate(
      workers: workers,
      attendanceRecords: attendanceRecords,
    );

    // Base:
    // Ramesh = ₹900
    // Suresh = ₹350
    //
    // OT:
    // Ramesh = 2 × ₹150 = ₹300
    // Suresh half-day OT = ₹0
    //
    // Total = ₹1550

    expect(summary.baseLabourCost, 1250);
    expect(summary.overtimeCost, 300);
    expect(summary.totalLabourCost, 1550);
  });

  test('ignores attendance records for unknown workers', () {
    final attendanceRecords = [
      WorkerAttendance(
        id: 'attendance-1',
        workerId: 'unknown-worker',
        projectId: 'project-1',
        date: DateTime(2026, 9, 20),
        status: AttendanceStatus.present,
        hoursWorked: 8,
        overtimeHours: 5,
      ),
    ];

    final summary = calculator.calculate(
      workers: workers,
      attendanceRecords: attendanceRecords,
    );

    expect(summary.totalWorkers, 1);
    expect(summary.presentWorkers, 0);
    expect(summary.baseLabourCost, 0);
    expect(summary.overtimeCost, 0);
    expect(summary.totalLabourCost, 0);
  });
}