import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/labour_cost_summary.dart';
import '../../domain/services/labour_cost_summary_calculator.dart';
import 'worker_attendance_providers.dart';
import 'worker_providers.dart';

class LabourCostSummaryFilter {
  const LabourCostSummaryFilter({
    required this.projectId,
    this.startDate,
    this.endDate,
  });

  final String projectId;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  bool operator ==(Object other) {
    return other is LabourCostSummaryFilter &&
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

final labourCostSummaryCalculatorProvider =
    Provider<LabourCostSummaryCalculator>((ref) {
  return const LabourCostSummaryCalculator();
});

final labourCostSummaryProvider =
    FutureProvider.family<LabourCostSummary, LabourCostSummaryFilter>(
  (ref, filter) async {
    final workers = await ref.watch(workersProvider.future);

    final repository = ref.watch(
      workerAttendanceRepositoryProvider,
    );

    final attendanceRecords = await repository.getProjectAttendance(
      projectId: filter.projectId,
      startDate: filter.startDate,
      endDate: filter.endDate,
    );

    final calculator = ref.watch(
      labourCostSummaryCalculatorProvider,
    );

    return calculator.calculate(
      workers: workers,
      attendanceRecords: attendanceRecords,
    );
  },
);