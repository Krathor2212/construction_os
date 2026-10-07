import 'package:flutter_test/flutter_test.dart';

import 'package:construction_os/features/workforce/domain/entities/worker.dart';
import 'package:construction_os/features/workforce/domain/entities/worker_attendance.dart';
import 'package:construction_os/features/workforce/domain/services/task_labour_calculator.dart';

void main() {
  const calculator = TaskLabourCalculator();

  final worker = Worker(
    id: 'worker-001',
    name: 'Ramesh',
    role: WorkerRole.mason,
    phone: '9000000001',
    dailyWage: 900,
    overtimeRate: 150,
  );

  test('calculates task labour from assigned worker attendance', () {
    final result = calculator.calculate(
      assignedWorkers: [worker],
      attendanceRecords: [
        WorkerAttendance(
          id: 'attendance-001',
          workerId: worker.id,
          date: DateTime(2026, 9, 22),
          status: AttendanceStatus.present,
          hoursWorked: 8,
          overtimeHours: 2,
        ),
      ],
    );

    expect(result.attendanceRecordCount, 1);
    expect(result.totalHoursWorked, 8);
    expect(result.totalOvertimeHours, 2);
    expect(result.baseLabourCost, 900);
    expect(result.overtimeCost, 300);
    expect(result.totalLabourCost, 1200);
  });

  test('ignores attendance for workers not assigned to the task', () {
    final result = calculator.calculate(
      assignedWorkers: [worker],
      attendanceRecords: [
        WorkerAttendance(
          id: 'attendance-002',
          workerId: 'worker-unknown',
          date: DateTime(2026, 9, 22),
          status: AttendanceStatus.present,
          hoursWorked: 8,
          overtimeHours: 1,
        ),
      ],
    );

    expect(result.attendanceRecordCount, 0);
    expect(result.totalLabourCost, 0);
  });
}
