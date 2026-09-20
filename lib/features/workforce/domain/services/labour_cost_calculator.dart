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
}