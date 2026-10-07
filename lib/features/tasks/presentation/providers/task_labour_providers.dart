import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../workforce/domain/entities/task_labour_summary.dart';
import '../../../workforce/domain/services/task_labour_calculator.dart';
import '../../../workforce/presentation/providers/worker_attendance_providers.dart';
import '../../../workforce/presentation/providers/worker_providers.dart';
import '../../domain/entities/project_task.dart';

final taskLabourCalculatorProvider = Provider<TaskLabourCalculator>((ref) {
  return const TaskLabourCalculator();
});

final taskLabourSummaryProvider =
    FutureProvider.family<TaskLabourSummary, ProjectTask>((ref, task) async {
  final workers = await ref.watch(workersProvider.future);
  final assignedWorkers = workers
      .where((worker) => task.assignedWorkerIds.contains(worker.id))
      .toList();

  final repository = ref.watch(workerAttendanceRepositoryProvider);
  final endDate = task.actualEndDate ?? task.plannedEndDate;
  final attendanceRecords = await Future.wait(
    assignedWorkers.map(
      (worker) => repository.getAttendance(
        workerId: worker.id,
        startDate: task.plannedStartDate,
        endDate: endDate,
      ),
    ),
  );

  final taskAttendance = attendanceRecords
      .expand((records) => records)
      .where(
        (attendance) =>
            attendance.projectId == task.projectId &&
            attendance.phaseId == task.phaseId,
      )
      .toList();

  return ref.read(taskLabourCalculatorProvider).calculate(
        assignedWorkers: assignedWorkers,
        attendanceRecords: taskAttendance,
      );
});
