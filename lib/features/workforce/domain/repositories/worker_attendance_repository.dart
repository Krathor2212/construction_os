import '../entities/worker_attendance.dart';

abstract interface class WorkerAttendanceRepository {
  Future<List<WorkerAttendance>> getAttendance({
    required String workerId,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<WorkerAttendance> getAttendanceRecord(
    String id,
  );

  Future<WorkerAttendance> createAttendance(
    WorkerAttendance attendance,
  );

  Future<WorkerAttendance> updateAttendance(
    WorkerAttendance attendance,
  );

  Future<void> deleteAttendance(
    String id,
  );
}