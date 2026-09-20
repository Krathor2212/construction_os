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
    phone: '9876543210',
    dailyWage: 900,
  );

  group('LabourCostCalculator', () {
    test('calculates full daily wage for present worker', () {
      final attendance = WorkerAttendance(
        id: 'attendance-001',
        workerId: worker.id,
        date: DateTime(2026, 9, 20),
        status: AttendanceStatus.present,
        hoursWorked: 8,
      );

      final cost = calculator.calculateBaseCost(
        worker: worker,
        attendance: attendance,
      );

      expect(cost, 900);
    });

    test('calculates half daily wage for half-day worker', () {
      final attendance = WorkerAttendance(
        id: 'attendance-002',
        workerId: worker.id,
        date: DateTime(2026, 9, 20),
        status: AttendanceStatus.halfDay,
        hoursWorked: 4,
      );

      final cost = calculator.calculateBaseCost(
        worker: worker,
        attendance: attendance,
      );

      expect(cost, 450);
    });

    test('calculates zero cost for absent worker', () {
      final attendance = WorkerAttendance(
        id: 'attendance-003',
        workerId: worker.id,
        date: DateTime(2026, 9, 20),
        status: AttendanceStatus.absent,
        hoursWorked: 0,
      );

      final cost = calculator.calculateBaseCost(
        worker: worker,
        attendance: attendance,
      );

      expect(cost, 0);
    });

    test('calculates zero cost for worker on leave', () {
      final attendance = WorkerAttendance(
        id: 'attendance-004',
        workerId: worker.id,
        date: DateTime(2026, 9, 20),
        status: AttendanceStatus.leave,
        hoursWorked: 0,
      );

      final cost = calculator.calculateBaseCost(
        worker: worker,
        attendance: attendance,
      );

      expect(cost, 0);
    });
  });
}