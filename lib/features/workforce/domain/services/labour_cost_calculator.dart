import '../entities/worker.dart';
import '../entities/worker_attendance.dart';

class LabourCostCalculator {
  const LabourCostCalculator();

  double calculateBaseCost({
    required Worker worker,
    required WorkerAttendance attendance,
  }) {
    switch (attendance.status) {
      case AttendanceStatus.present:
        return worker.dailyWage;
      case AttendanceStatus.halfDay:
        return worker.dailyWage * 0.5;
      case AttendanceStatus.absent:
      case AttendanceStatus.leave:
        return 0;
    }
  }

  double calculateOvertimeCost({
    required Worker worker,
    required WorkerAttendance attendance,
  }) {
    if (attendance.status != AttendanceStatus.present) {
      return 0;
    }

    return attendance.overtimeHours * worker.overtimeRate;
  }

  double calculateTotalCost({
    required Worker worker,
    required WorkerAttendance attendance,
  }) {
    final baseCost = calculateBaseCost(
      worker: worker,
      attendance: attendance,
    );

    final overtimeCost = calculateOvertimeCost(
      worker: worker,
      attendance: attendance,
    );

    return baseCost + overtimeCost;
  }
}