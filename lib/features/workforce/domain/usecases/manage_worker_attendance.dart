import '../entities/worker_attendance.dart';
import '../repositories/worker_attendance_repository.dart';

class ManageWorkerAttendance {
  const ManageWorkerAttendance(
    this.repository,
  );

  final WorkerAttendanceRepository repository;

  Future<WorkerAttendance> create(
    WorkerAttendance attendance,
  ) async {
    return repository.createAttendance(
      attendance,
    );
  }

  Future<WorkerAttendance> update(
    WorkerAttendance attendance,
  ) async {
    return repository.updateAttendance(
      attendance,
    );
  }

  Future<void> delete(
    String id,
  ) async {
    await repository.deleteAttendance(id);
  }
}