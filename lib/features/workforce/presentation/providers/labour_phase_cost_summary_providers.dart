import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../projects/presentation/providers/project_providers.dart';
import '../../domain/entities/labour_phase_cost_summary.dart';
import '../../domain/services/labour_phase_cost_summary_calculator.dart';
import 'worker_attendance_providers.dart';
import 'worker_providers.dart';

class LabourPhaseCostSummaryFilter {
  const LabourPhaseCostSummaryFilter({
    required this.projectId,
    this.startDate,
    this.endDate,
  });

  final String projectId;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  bool operator ==(Object other) {
    return other is LabourPhaseCostSummaryFilter &&
        other.projectId == projectId &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode => Object.hash(
        projectId,
        startDate,
        endDate,
      );
}

final labourPhaseCostSummaryCalculatorProvider =
    Provider<LabourPhaseCostSummaryCalculator>((ref) {
  return const LabourPhaseCostSummaryCalculator();
});

final labourPhaseCostSummaryProvider = FutureProvider.family<
    List<LabourPhaseCostSummary>,
    LabourPhaseCostSummaryFilter>(
  (ref, filter) async {
    final phases = await ref.watch(
      projectPhasesProvider(filter.projectId).future,
    );

    final workers = await ref.watch(
      workersProvider.future,
    );

    final repository = ref.watch(
      workerAttendanceRepositoryProvider,
    );

    final attendanceRecords = await repository.getProjectAttendance(
      projectId: filter.projectId,
      startDate: filter.startDate,
      endDate: filter.endDate,
    );

    final calculator = ref.watch(
      labourPhaseCostSummaryCalculatorProvider,
    );

    return calculator.calculate(
      phases: phases,
      workers: workers,
      attendanceRecords: attendanceRecords,
    );
  },
);