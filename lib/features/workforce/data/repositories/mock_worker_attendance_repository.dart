import '../../domain/entities/worker_attendance.dart';
import '../../domain/repositories/worker_attendance_repository.dart';

class MockWorkerAttendanceRepository
    implements WorkerAttendanceRepository {
  final List<WorkerAttendance> _attendance = [
    WorkerAttendance(
      id: 'worker-attendance-001',
      workerId: 'worker-001',
      date: DateTime(2026, 9, 20),
      status: AttendanceStatus.present,
      projectId: 'project-001',
      phaseId: 'phase-001',
      hoursWorked: 8,
      overtimeHours: 0,
      notes: 'Worked on foundation masonry.',
    ),
    WorkerAttendance(
      id: 'worker-attendance-002',
      workerId: 'worker-002',
      date: DateTime(2026, 9, 20),
      status: AttendanceStatus.present,
      projectId: 'project-001',
      phaseId: 'phase-001',
      hoursWorked: 8,
      overtimeHours: 1,
      notes: 'Assisted foundation work.',
    ),
    WorkerAttendance(
      id: 'worker-attendance-003',
      workerId: 'worker-003',
      date: DateTime(2026, 9, 20),
      status: AttendanceStatus.halfDay,
      projectId: 'project-001',
      phaseId: 'phase-001',
      hoursWorked: 4,
      overtimeHours: 0,
    ),
    WorkerAttendance(
      id: 'worker-attendance-004',
      workerId: 'worker-004',
      date: DateTime(2026, 9, 20),
      status: AttendanceStatus.absent,
      projectId: 'project-001',
      phaseId: 'phase-001',
      hoursWorked: 0,
      overtimeHours: 0,
      notes: 'Not available today.',
    ),
  ];

  @override
  Future<List<WorkerAttendance>> getAttendance({
    required String workerId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return _attendance.where((attendance) {
      if (attendance.workerId != workerId) {
        return false;
      }

      if (startDate != null &&
          attendance.date.isBefore(startDate)) {
        return false;
      }

      if (endDate != null &&
          attendance.date.isAfter(endDate)) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Future<WorkerAttendance> getAttendanceRecord(
    String id,
  ) async {
    return _attendance.firstWhere(
      (attendance) => attendance.id == id,
      orElse: () {
        throw StateError(
          'Attendance record $id not found.',
        );
      },
    );
  }

  @override
  Future<WorkerAttendance> createAttendance(
    WorkerAttendance attendance,
  ) async {
    _attendance.add(attendance);
    return attendance;
  }

  @override
  Future<WorkerAttendance> updateAttendance(
    WorkerAttendance attendance,
  ) async {
    final index = _attendance.indexWhere(
      (existing) => existing.id == attendance.id,
    );

    if (index == -1) {
      throw StateError(
        'Attendance record ${attendance.id} not found.',
      );
    }

    _attendance[index] = attendance;
    return attendance;
  }

  @override
  Future<void> deleteAttendance(
    String id,
  ) async {
    _attendance.removeWhere(
      (attendance) => attendance.id == id,
    );
  }
}