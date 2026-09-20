import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_worker_attendance_repository.dart';
import '../../domain/entities/worker_attendance.dart';
import '../../domain/repositories/worker_attendance_repository.dart';

final workerAttendanceRepositoryProvider =
    Provider<WorkerAttendanceRepository>((ref) {
  return MockWorkerAttendanceRepository();
});

final workerAttendanceProvider =
    FutureProvider.family<
        List<WorkerAttendance>,
        String>(
  (ref, workerId) async {
    final repository = ref.watch(
      workerAttendanceRepositoryProvider,
    );

    return repository.getAttendance(
      workerId: workerId,
    );
  },
);

final workerAttendanceByDateRangeProvider =
    FutureProvider.family<
        List<WorkerAttendance>,
        WorkerAttendanceDateRange>(
  (ref, range) async {
    final repository = ref.watch(
      workerAttendanceRepositoryProvider,
    );

    return repository.getAttendance(
      workerId: range.workerId,
      startDate: range.startDate,
      endDate: range.endDate,
    );
  },
);

class WorkerAttendanceDateRange {
  const WorkerAttendanceDateRange({
    required this.workerId,
    this.startDate,
    this.endDate,
  });

  final String workerId;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  bool operator ==(Object other) {
    return other is WorkerAttendanceDateRange &&
        other.workerId == workerId &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode => Object.hash(
        workerId,
        startDate,
        endDate,
      );
}

final workerAttendanceRecordProvider =
    FutureProvider.family<
        WorkerAttendance,
        String>(
  (ref, attendanceId) async {
    final repository = ref.watch(
      workerAttendanceRepositoryProvider,
    );

    return repository.getAttendanceRecord(
      attendanceId,
    );
  },
);