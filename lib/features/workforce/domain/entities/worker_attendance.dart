class WorkerAttendance {
  const WorkerAttendance({
    required this.id,
    required this.workerId,
    required this.date,
    required this.status,
    this.projectId,
    this.phaseId,
    this.hoursWorked = 0,
    this.overtimeHours = 0,
    this.notes,
  });

  final String id;
  final String workerId;
  final DateTime date;
  final AttendanceStatus status;
  final String? projectId;
  final String? phaseId;
  final double hoursWorked;
  final double overtimeHours;
  final String? notes;
}

enum AttendanceStatus {
  present,
  halfDay,
  absent,
  leave,
}