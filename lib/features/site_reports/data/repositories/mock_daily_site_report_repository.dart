import '../../domain/entities/daily_site_report.dart';
import '../../domain/repositories/daily_site_report_repository.dart';

class MockDailySiteReportRepository
    implements DailySiteReportRepository {
  final List<DailySiteReport> _reports = [
    DailySiteReport(
      id: 'site-report-001',
      projectId: 'project-001',
      phaseId: 'phase-001',
      date: DateTime(2026, 9, 20),
      workCompleted:
          'Completed foundation masonry for the north section.',
      workPlannedForNextDay:
          'Continue foundation masonry and start column reinforcement.',
      issuesAndDelays:
          'Material delivery was delayed by approximately one hour.',
      safetyNotes:
          'Workers used helmets and safety shoes throughout the shift.',
      qualityNotes:
          'Masonry alignment and level were checked before closing the work area.',
      generalNotes:
          'Overall progress was satisfactory.',
    ),
    DailySiteReport(
      id: 'site-report-002',
      projectId: 'project-001',
      phaseId: 'phase-001',
      date: DateTime(2026, 9, 21),
      workCompleted:
          'Completed remaining foundation masonry and prepared column locations.',
      workPlannedForNextDay:
          'Begin column reinforcement and shuttering preparation.',
      issuesAndDelays:
          'No significant delays reported.',
      safetyNotes:
          'Daily safety briefing conducted before work started.',
      qualityNotes:
          'Foundation dimensions and levels were verified.',
      generalNotes:
          'Site activities progressed according to plan.',
    ),
  ];

  @override
  Future<List<DailySiteReport>> getReports({
    required String projectId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return _reports.where((report) {
      if (report.projectId != projectId) {
        return false;
      }

      if (startDate != null &&
          report.date.isBefore(startDate)) {
        return false;
      }

      if (endDate != null &&
          report.date.isAfter(endDate)) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Future<DailySiteReport> getReport(
    String id,
  ) async {
    return _reports.firstWhere(
      (report) => report.id == id,
      orElse: () {
        throw StateError(
          'Daily site report $id not found.',
        );
      },
    );
  }

  @override
  Future<DailySiteReport> createReport(
    DailySiteReport report,
  ) async {
    _reports.add(report);
    return report;
  }

  @override
  Future<DailySiteReport> updateReport(
    DailySiteReport report,
  ) async {
    final index = _reports.indexWhere(
      (existing) => existing.id == report.id,
    );

    if (index == -1) {
      throw StateError(
        'Daily site report ${report.id} not found.',
      );
    }

    _reports[index] = report;
    return report;
  }

  @override
  Future<void> deleteReport(
    String id,
  ) async {
    _reports.removeWhere(
      (report) => report.id == id,
    );
  }
}