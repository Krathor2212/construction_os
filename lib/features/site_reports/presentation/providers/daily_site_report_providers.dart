import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_daily_site_report_repository.dart';
import '../../domain/entities/daily_site_report.dart';
import '../../domain/repositories/daily_site_report_repository.dart';

final dailySiteReportRepositoryProvider =
    Provider<DailySiteReportRepository>((ref) {
  return MockDailySiteReportRepository();
});

final dailySiteReportsProvider =
    FutureProvider.family<List<DailySiteReport>, DailySiteReportFilter>(
  (ref, filter) async {
    final repository = ref.watch(
      dailySiteReportRepositoryProvider,
    );

    return repository.getReports(
      projectId: filter.projectId,
      startDate: filter.startDate,
      endDate: filter.endDate,
    );
  },
);

final dailySiteReportProvider =
    FutureProvider.family<DailySiteReport, String>(
  (ref, reportId) async {
    final repository = ref.watch(
      dailySiteReportRepositoryProvider,
    );

    return repository.getReport(reportId);
  },
);

class DailySiteReportFilter {
  const DailySiteReportFilter({
    required this.projectId,
    this.startDate,
    this.endDate,
  });

  final String projectId;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  bool operator ==(Object other) {
    return other is DailySiteReportFilter &&
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