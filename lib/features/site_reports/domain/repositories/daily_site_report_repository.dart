import '../entities/daily_site_report.dart';

abstract interface class DailySiteReportRepository {
  Future<List<DailySiteReport>> getReports({
    required String projectId,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<DailySiteReport> getReport(
    String id,
  );

  Future<DailySiteReport> createReport(
    DailySiteReport report,
  );

  Future<DailySiteReport> updateReport(
    DailySiteReport report,
  );

  Future<void> deleteReport(
    String id,
  );
}