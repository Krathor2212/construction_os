import 'package:flutter_test/flutter_test.dart';

import 'package:construction_os/features/site_reports/data/repositories/mock_daily_site_report_repository.dart';

void main() {
  test('returns reports linked to the excavation task', () async {
    final repository = MockDailySiteReportRepository();

    final reports = await repository.getReports(projectId: 'project-001');

    expect(
      reports.where((report) => report.taskIds.contains('task-001')).length,
      2,
    );
  });
}
