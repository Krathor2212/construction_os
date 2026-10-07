import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../tasks/domain/entities/project_task.dart';
import '../../domain/entities/daily_site_report.dart';
import 'daily_site_report_providers.dart';

final taskDailySiteReportsProvider =
    FutureProvider.family<List<DailySiteReport>, ProjectTask>(
  (ref, task) async {
    final repository = ref.watch(dailySiteReportRepositoryProvider);
    final reports = await repository.getReports(
      projectId: task.projectId,
    );

    return reports
        .where((report) => report.taskIds.contains(task.id))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  },
);
