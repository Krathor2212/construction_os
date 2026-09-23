import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../projects/domain/entities/project_phase.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../domain/entities/daily_site_report.dart';
import '../providers/daily_site_report_providers.dart';
import '../widgets/daily_site_report_form_dialog.dart';

class DailySiteReportsPage extends ConsumerWidget {
  const DailySiteReportsPage({
    super.key,
    required this.projectId,
  });

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(
      dailySiteReportsProvider(
        DailySiteReportFilter(
          projectId: projectId,
        ),
      ),
    );

    final phasesAsync = ref.watch(
      projectPhasesProvider(projectId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Site Reports'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addReport(
          context,
          ref,
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Report'),
      ),
      body: reportsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => _ErrorState(
          message: error.toString(),
          onRetry: () {
            ref.invalidate(
              dailySiteReportsProvider(
                DailySiteReportFilter(
                  projectId: projectId,
                ),
              ),
            );
          },
        ),
        data: (reports) {
          if (reports.isEmpty) {
            return _EmptyState(
              onAddReport: () => _addReport(
                context,
                ref,
              ),
            );
          }

          final phases = phasesAsync.when(
            data: (value) => value,
            loading: () => const <ProjectPhase>[],
            error: (_, _) => const <ProjectPhase>[],
          );

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                dailySiteReportsProvider(
                  DailySiteReportFilter(
                    projectId: projectId,
                  ),
                ),
              );

              await ref.read(
                dailySiteReportsProvider(
                  DailySiteReportFilter(
                    projectId: projectId,
                  ),
                ).future,
              );
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                96,
              ),
              children: [
                _SummaryHeader(
                  reportCount: reports.length,
                ),
                const SizedBox(height: 16),
                ...reports.map(
                  (report) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: 12,
                    ),
                    child: _ReportCard(
                      report: report,
                      phaseName: _phaseName(
                        phases,
                        report.phaseId,
                      ),
                      onTap: () => _openReport(
                        context,
                        ref,
                        report,
                      ),
                      onEdit: () => _editReport(
                        context,
                        ref,
                        report,
                      ),
                      onDelete: () => _deleteReport(
                        context,
                        ref,
                        report,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _addReport(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final report = await showDialog<DailySiteReport>(
      context: context,
      builder: (_) => const DailySiteReportFormDialog(),
    );

    if (report == null) {
      return;
    }

    final repository = ref.read(
      dailySiteReportRepositoryProvider,
    );

    await repository.createReport(report);

    ref.invalidate(
      dailySiteReportsProvider(
        DailySiteReportFilter(
          projectId: projectId,
        ),
      ),
    );
  }

  Future<void> _editReport(
    BuildContext context,
    WidgetRef ref,
    DailySiteReport report,
  ) async {
    final updatedReport = await showDialog<DailySiteReport>(
      context: context,
      builder: (_) => DailySiteReportFormDialog(
        initialReport: report,
      ),
    );

    if (updatedReport == null) {
      return;
    }

    final repository = ref.read(
      dailySiteReportRepositoryProvider,
    );

    await repository.updateReport(updatedReport);

    ref.invalidate(
      dailySiteReportsProvider(
        DailySiteReportFilter(
          projectId: projectId,
        ),
      ),
    );

    ref.invalidate(
      dailySiteReportProvider(
        report.id,
      ),
    );
  }

  Future<void> _deleteReport(
    BuildContext context,
    WidgetRef ref,
    DailySiteReport report,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Site Report?'),
          content: const Text(
            'This report will be permanently removed.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final repository = ref.read(
      dailySiteReportRepositoryProvider,
    );

    await repository.deleteReport(
      report.id,
    );

    ref.invalidate(
      dailySiteReportsProvider(
        DailySiteReportFilter(
          projectId: projectId,
        ),
      ),
    );

    ref.invalidate(
      dailySiteReportProvider(
        report.id,
      ),
    );
  }

  Future<void> _openReport(
    BuildContext context,
    WidgetRef ref,
    DailySiteReport report,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _ReportDetailsDialog(
        report: report,
      ),
    );
  }

  String _phaseName(
    List<ProjectPhase> phases,
    String? phaseId,
  ) {
    if (phaseId == null) {
      return 'Whole Project';
    }

    for (final phase in phases) {
      if (phase.id == phaseId) {
        return phase.name;
      }
    }

    return 'Unknown Phase';
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({
    required this.reportCount,
  });

  final int reportCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              child: Icon(Icons.description_outlined),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Site Reports',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$reportCount report${reportCount == 1 ? '' : 's'} recorded',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.report,
    required this.phaseName,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final DailySiteReport report;
  final String phaseName;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final formattedDate = MaterialLocalizations.of(
      context,
    ).formatMediumDate(report.date);

    final hasIssues =
        report.issuesAndDelays.trim().isNotEmpty;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          formattedDate,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          phaseName,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) {
                      return const [
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ];
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                report.workCompleted,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.construction_outlined,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Work completed',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall,
                  ),
                  if (hasIssues) ...[
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.warning_amber_outlined,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Issues reported',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportDetailsDialog extends StatelessWidget {
  const _ReportDetailsDialog({
    required this.report,
  });

  final DailySiteReport report;

  @override
  Widget build(BuildContext context) {
    final formattedDate = MaterialLocalizations.of(
      context,
    ).formatMediumDate(report.date);

    return AlertDialog(
      title: Text(
        'Site Report • $formattedDate',
      ),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _DetailSection(
                title: 'Work Completed',
                content: report.workCompleted,
              ),
              _DetailSection(
                title: 'Work Planned for Next Day',
                content: report.workPlannedForNextDay,
              ),
              _DetailSection(
                title: 'Issues & Delays',
                content: report.issuesAndDelays,
              ),
              _DetailSection(
                title: 'Safety Notes',
                content: report.safetyNotes,
              ),
              _DetailSection(
                title: 'Quality Notes',
                content: report.qualityNotes,
              ),
              if (report.generalNotes != null &&
                  report.generalNotes!.trim().isNotEmpty)
                _DetailSection(
                  title: 'General Notes',
                  content: report.generalNotes!,
                ),
            ],
          ),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleSmall,
          ),
          const SizedBox(height: 6),
          Text(
            content.trim().isEmpty
                ? 'No information recorded.'
                : content,
            style: Theme.of(context)
                .textTheme
                .bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.onAddReport,
  });

  final VoidCallback onAddReport;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No site reports yet',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Record daily site activities, progress, '
              'issues, safety, and quality observations.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAddReport,
              icon: const Icon(Icons.add),
              label: const Text('Add Site Report'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to load site reports.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}