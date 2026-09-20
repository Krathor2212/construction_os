import 'package:flutter_test/flutter_test.dart';

import 'package:construction_os/features/workforce/domain/entities/worker.dart';
import 'package:construction_os/features/workforce/domain/entities/worker_attendance.dart';
import 'package:construction_os/features/workforce/domain/services/labour_cost_calculator.dart';

void main() {
  const calculator = LabourCostCalculator();

  const worker = Worker(
    id: 'worker-001',
    name: 'Ramesh',
    role: WorkerRole.mason,
    phone: '+91 98765 10001',
    dailyWage: 900,
    overtimeRate: 150,
  );

  test('calculates full-day base cost', () {
    final attendance = WorkerAttendance(
      id: 'attendance-001',
      workerId: worker.id,
      projectId: 'project-001',
      date: DateTime(2026, 9, 20),
      status: AttendanceStatus.present,
      hoursWorked: 8,
      overtimeHours: 0,
    );

    final result = calculator.calculateBaseCost(
      worker: worker,
      attendance: attendance,
    );

    expect(result, 900);
  });

  test('calculates half-day base cost', () {
    final attendance = WorkerAttendance(
      id: 'attendance-002',
      workerId: worker.id,
      projectId: 'project-001',
      date: DateTime(2026, 9, 20),
      status: AttendanceStatus.halfDay,
      hoursWorked: 4,
      overtimeHours: 0,
    );

    final result = calculator.calculateBaseCost(
      worker: worker,
      attendance: attendance,
    );

    expect(result, 450);
  });

  test('calculates overtime cost for present worker', () {
    final attendance = WorkerAttendance(
      id: 'attendance-003',
      workerId: worker.id,
      projectId: 'project-001',
      date: DateTime(2026, 9, 20),
      status: AttendanceStatus.present,
      hoursWorked: 10,
      overtimeHours: 2,
    );

    final result = calculator.calculateOvertimeCost(
      worker: worker,
      attendance: attendance,
    );

    expect(result, 300);
  });

  test('calculates total cost including overtime', () {
    final attendance = WorkerAttendance(
      id: 'attendance-004',
      workerId: worker.id,
      projectId: 'project-001',
      date: DateTime(2026, 9, 20),
      status: AttendanceStatus.present,
      hoursWorked: 10,
      overtimeHours: 2,
    );

    final result = calculator.calculateTotalCost(
      worker: worker,
      attendance: attendance,
    );

    expect(result, 1200);
  });

  test('does not pay overtime for half-day worker', () {
    final attendance = WorkerAttendance(
      id: 'attendance-005',
      workerId: worker.id,
      projectId: 'project-001',
      date: DateTime(2026, 9, 20),
      status: AttendanceStatus.halfDay,
      hoursWorked: 4,
      overtimeHours: 2,
    );

    final result = calculator.calculateOvertimeCost(
      worker: worker,
      attendance: attendance,
    );

    expect(result, 0);
  });

  test('does not pay overtime for absent worker', () {
    final attendance = WorkerAttendance(
      id: 'attendance-006',
      workerId: worker.id,
      projectId: 'project-001',
      date: DateTime(2026, 9, 20),
      status: AttendanceStatus.absent,
      hoursWorked: 0,
      overtimeHours: 2,
    );

    final result = calculator.calculateOvertimeCost(
      worker: worker,
      attendance: attendance,
    );

    expect(result, 0);
  });

  test('does not pay overtime for worker on leave', () {
    final attendance = WorkerAttendance(
      id: 'attendance-007',
      workerId: worker.id,
      projectId: 'project-001',
      date: DateTime(2026, 9, 20),
      status: AttendanceStatus.leave,
      hoursWorked: 0,
      overtimeHours: 2,
    );

    final result = calculator.calculateOvertimeCost(
      worker: worker,
      attendance: attendance,
    );

    expect(result, 0);
  });

  test('calculates zero overtime when overtime rate is zero', () {
    const workerWithoutOvertime = Worker(
      id: 'worker-002',
      name: 'Suresh',
      role: WorkerRole.helper,
      phone: '+91 98765 10002',
      dailyWage: 650,
    );

    final attendance = WorkerAttendance(
      id: 'attendance-008',
      workerId: workerWithoutOvertime.id,
      projectId: 'project-001',
      date: DateTime(2026, 9, 20),
      status: AttendanceStatus.present,
      hoursWorked: 10,
      overtimeHours: 2,
    );

    final result = calculator.calculateOvertimeCost(
      worker: workerWithoutOvertime,
      attendance: attendance,
    );

    expect(result, 0);
  });
}