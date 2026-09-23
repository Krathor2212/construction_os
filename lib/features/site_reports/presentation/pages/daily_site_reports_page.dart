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
                        phaseName: _phaseName(
                          phases,
                          report.phaseId,
                        ),
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
    DailySiteReport report, {
    required String phaseName,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _ReportDetailsDialog(
        report: report,
        phaseName: phaseName,
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
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.description_outlined,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Site Reports',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$reportCount report'
                    '${reportCount == 1 ? '' : 's'} recorded',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.outline,
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
    final theme = Theme.of(context);

    final formattedDate = MaterialLocalizations.of(
      context,
    ).formatMediumDate(report.date);

    final hasIssues =
        report.issuesAndDelays.trim().isNotEmpty;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
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
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 17,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                formattedDate,
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme
                                .surfaceContainerHighest,
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: Text(
                            phaseName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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
              const SizedBox(height: 16),
              Text(
                'Work Completed',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                report.workCompleted,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(
                    Icons.construction_outlined,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Work recorded',
                    style: theme.textTheme.bodySmall,
                  ),
                  if (hasIssues) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.warning_amber_outlined,
                      size: 18,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Issues reported',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
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
    required this.phaseName,
  });

  final DailySiteReport report;
  final String phaseName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final formattedDate = MaterialLocalizations.of(
      context,
    ).formatMediumDate(report.date);

    final hasIssues =
        report.issuesAndDelays.trim().isNotEmpty;

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(
        24,
        24,
        24,
        8,
      ),
      contentPadding: const EdgeInsets.fromLTRB(
        24,
        8,
        24,
        8,
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        24,
        8,
        24,
        20,
      ),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              Icons.description_outlined,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Site Report',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ReportContextCard(
                date: formattedDate,
                phaseName: phaseName,
              ),
              const SizedBox(height: 18),
              _DetailSection(
                icon: Icons.construction_outlined,
                title: 'Work Completed',
                content: report.workCompleted,
              ),
              _DetailSection(
                icon: Icons.next_plan_outlined,
                title: 'Work Planned for Next Day',
                content: report.workPlannedForNextDay,
              ),
              _DetailSection(
                icon: Icons.warning_amber_outlined,
                title: 'Issues & Delays',
                content: report.issuesAndDelays,
                isHighlighted: hasIssues,
              ),
              _DetailSection(
                icon: Icons.health_and_safety_outlined,
                title: 'Safety Notes',
                content: report.safetyNotes,
              ),
              _DetailSection(
                icon: Icons.verified_outlined,
                title: 'Quality Notes',
                content: report.qualityNotes,
              ),
              if (report.generalNotes != null &&
                  report.generalNotes!.trim().isNotEmpty)
                _DetailSection(
                  icon: Icons.notes_outlined,
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

class _ReportContextCard extends StatelessWidget {
  const _ReportContextCard({
    required this.date,
    required this.phaseName,
  });

  final String date;
  final String phaseName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Wrap(
        spacing: 24,
        runSpacing: 12,
        children: [
          _ContextItem(
            icon: Icons.calendar_today_outlined,
            label: 'Report Date',
            value: date,
          ),
          _ContextItem(
            icon: Icons.account_tree_outlined,
            label: 'Phase',
            value: phaseName,
          ),
        ],
      ),
    );
  }
}

class _ContextItem extends StatelessWidget {
  const _ContextItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall,
            ),
            const SizedBox(height: 2),
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 240,
              ),
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.icon,
    required this.title,
    required this.content,
    this.isHighlighted = false,
  });

  final IconData icon;
  final String title;
  final String content;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isEmpty = content.trim().isEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isHighlighted
              ? theme.colorScheme.errorContainer
              : theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isHighlighted
                ? theme.colorScheme.error.withValues(alpha: 0.35)
                : theme.colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isHighlighted
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isHighlighted
                          ? theme.colorScheme.onErrorContainer
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              isEmpty
                  ? 'No information recorded.'
                  : content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isEmpty
                    ? theme.colorScheme.onSurfaceVariant
                    : null,
                height: 1.5,
              ),
            ),
          ],
        ),
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
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.description_outlined,
                size: 44,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No site reports yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Record daily site activities, progress, '
              'issues, safety, and quality observations.',
              style: theme.textTheme.bodyMedium,
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
          mainAxisAlignment: MainAxisAlignment.center,
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