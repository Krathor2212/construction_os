import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/project_phase.dart';
import '../providers/project_providers.dart';
import '../widgets/phase_form_dialog.dart';

class ProjectTimelinePage extends ConsumerWidget {
  const ProjectTimelinePage({
    required this.projectId,
    super.key,
  });

  final String projectId;

  Future<void> _showPhaseForm(
    BuildContext context,
    WidgetRef ref, {
    ProjectPhase? phase,
  }) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => PhaseFormDialog(
        projectId: projectId,
        phase: phase,
      ),
    );

    if (saved == true) {
      ref.invalidate(
        projectPhasesProvider(projectId),
      );
    }
  }

  Future<void> _archivePhase(
    BuildContext context,
    WidgetRef ref,
    ProjectPhase phase,
  ) async {
    final shouldArchive = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Archive Phase?'),
          content: Text(
            'Are you sure you want to archive '
            '"${phase.name}"?\n\n'
            'The phase will be removed from the active '
            'timeline but retained in project history.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              icon: const Icon(
                Icons.archive_outlined,
              ),
              label: const Text('Archive'),
            ),
          ],
        );
      },
    );

    if (shouldArchive != true) {
      return;
    }

    try {
      final repository = ref.read(
        projectPhaseRepositoryProvider,
      );

      await repository.archivePhase(phase.id);

      ref.invalidate(
        projectPhasesProvider(projectId),
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${phase.name} archived successfully.',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to archive phase: $error',
          ),
        ),
      );
    }
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final phasesAsync = ref.watch(
      projectPhasesProvider(projectId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Timeline'),
      ),
      body: phasesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                ),
                const SizedBox(
                  height: AppSpacing.md,
                ),
                const Text(
                  'Unable to load project timeline.',
                ),
                const SizedBox(
                  height: AppSpacing.sm,
                ),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(
                      projectPhasesProvider(projectId),
                    );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (phases) {
          if (phases.isEmpty) {
            return const _EmptyTimelineView();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                projectPhasesProvider(projectId),
              );

              await ref.read(
                projectPhasesProvider(projectId).future,
              );
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(
                AppSpacing.md,
              ),
              itemCount: phases.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(
                height: AppSpacing.sm,
              ),
              itemBuilder: (context, index) {
                final phase = phases[index];

                return _PhaseCard(
                  phase: phase,
                  onEdit: () => _showPhaseForm(
                    context,
                    ref,
                    phase: phase,
                  ),
                  onArchive: () => _archivePhase(
                    context,
                    ref,
                    phase,
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () => _showPhaseForm(
          context,
          ref,
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Phase'),
      ),
    );
  }
}

class _PhaseCard extends StatelessWidget {
  const _PhaseCard({
    required this.phase,
    required this.onEdit,
    required this.onArchive,
  });

  final ProjectPhase phase;
  final VoidCallback onEdit;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    final status = _statusInfo(phase.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Icon(
                  status.icon,
                  size: 26,
                  color: status.color,
                ),
                const SizedBox(
                  width: AppSpacing.sm,
                ),
                Expanded(
                  child: Text(
                    phase.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge,
                  ),
                ),
                const SizedBox(
                  width: AppSpacing.xs,
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'archive') {
                      onArchive();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        contentPadding:
                            EdgeInsets.zero,
                        leading: Icon(
                          Icons.edit_outlined,
                        ),
                        title: Text('Edit'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'archive',
                      child: ListTile(
                        contentPadding:
                            EdgeInsets.zero,
                        leading: Icon(
                          Icons.archive_outlined,
                        ),
                        title: Text('Archive'),
                      ),
                    ),
                  ],
                ),
                Chip(
                  label: Text(status.label),
                  visualDensity:
                      VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(
              height: AppSpacing.md,
            ),
            Row(
              children: [
                Expanded(
                  child: _DateInfo(
                    label: 'Planned Start',
                    date: phase.plannedStartDate,
                  ),
                ),
                Expanded(
                  child: _DateInfo(
                    label: 'Planned End',
                    date: phase.plannedEndDate,
                  ),
                ),
              ],
            ),
            if (phase.actualStartDate != null ||
                phase.actualEndDate != null) ...[
              const SizedBox(
                height: AppSpacing.md,
              ),
              const Divider(),
              const SizedBox(
                height: AppSpacing.md,
              ),
              Row(
                children: [
                  Expanded(
                    child: _DateInfo(
                      label: 'Actual Start',
                      date: phase.actualStartDate,
                    ),
                  ),
                  Expanded(
                    child: _DateInfo(
                      label: 'Actual End',
                      date: phase.actualEndDate,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(
              height: AppSpacing.md,
            ),
            Row(
              children: [
                Text(
                  'Progress',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium,
                ),
                const Spacer(),
                Text(
                  '${phase.progress.toStringAsFixed(0)}%',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium,
                ),
              ],
            ),
            const SizedBox(
              height: AppSpacing.xs,
            ),
            LinearProgressIndicator(
              value:
                  (phase.progress / 100).clamp(0, 1),
              minHeight: 7,
              borderRadius:
                  BorderRadius.circular(10),
            ),
            if (phase.notes != null &&
                phase.notes!.isNotEmpty) ...[
              const SizedBox(
                height: AppSpacing.md,
              ),
              Text(
                phase.notes!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  _StatusInfo _statusInfo(
    ProjectPhaseStatus status,
  ) {
    return switch (status) {
      ProjectPhaseStatus.notStarted =>
        const _StatusInfo(
          label: 'Not Started',
          icon: Icons.radio_button_unchecked,
          color: Colors.grey,
        ),
      ProjectPhaseStatus.inProgress =>
        const _StatusInfo(
          label: 'In Progress',
          icon: Icons.play_circle_outline,
          color: Colors.blue,
        ),
      ProjectPhaseStatus.completed =>
        const _StatusInfo(
          label: 'Completed',
          icon: Icons.check_circle_outline,
          color: Colors.green,
        ),
      ProjectPhaseStatus.delayed =>
        const _StatusInfo(
          label: 'Delayed',
          icon: Icons.warning_amber_outlined,
          color: Colors.orange,
        ),
      ProjectPhaseStatus.onHold =>
        const _StatusInfo(
          label: 'On Hold',
          icon: Icons.pause_circle_outline,
          color: Colors.red,
        ),
    };
  }
}

class _StatusInfo {
  const _StatusInfo({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

class _DateInfo extends StatelessWidget {
  const _DateInfo({
    required this.label,
    required this.date,
  });

  final String label;
  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .labelMedium,
        ),
        const SizedBox(
          height: AppSpacing.xxs,
        ),
        Text(
          date == null
              ? '-'
              : _formatDate(date!),
          style: Theme.of(context)
              .textTheme
              .bodyMedium,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _EmptyTimelineView extends StatelessWidget {
  const _EmptyTimelineView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.timeline_outlined,
              size: 56,
            ),
            const SizedBox(
              height: AppSpacing.md,
            ),
            Text(
              'No timeline phases yet',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge,
            ),
            const SizedBox(
              height: AppSpacing.xs,
            ),
            Text(
              'Add project phases to start tracking '
              'the construction timeline.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}