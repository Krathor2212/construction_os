import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../../workforce/domain/entities/worker.dart';
import '../../../workforce/presentation/providers/worker_providers.dart';
import '../../../site_reports/presentation/providers/task_daily_site_report_providers.dart';
import '../../domain/entities/project_task.dart';
import '../../domain/entities/project_task_progress_update.dart';
import '../providers/project_task_providers.dart';
import '../providers/project_task_progress_providers.dart';
import '../providers/task_labour_providers.dart';
import '../widgets/project_task_form_dialog.dart';

class ProjectTaskDetailsPage extends ConsumerWidget {
  const ProjectTaskDetailsPage({
    super.key,
    required this.projectId,
    required this.taskId,
  });

  final String projectId;
  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskAsync = ref.watch(projectTaskProvider(taskId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          taskAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (task) => IconButton(
              tooltip: 'Edit task',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _editTask(context, ref, task),
            ),
          ),
        ],
      ),
      body: taskAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _TaskDetailsError(
          message: error.toString(),
          onRetry: () => ref.invalidate(projectTaskProvider(taskId)),
        ),
        data: (task) => _TaskDetailsContent(projectId: projectId, task: task),
      ),
    );
  }

  Future<void> _editTask(
    BuildContext context,
    WidgetRef ref,
    ProjectTask task,
  ) async {
    final updatedTask = await showDialog<ProjectTask>(
      context: context,
      builder: (_) => ProjectTaskFormDialog(projectId: projectId, task: task),
    );

    if (updatedTask == null || !context.mounted) {
      return;
    }

    await ref.read(projectTaskActionsProvider).updateTask(updatedTask);

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Task updated successfully.')));
  }
}

class _TaskDetailsContent extends ConsumerWidget {
  const _TaskDetailsContent({required this.projectId, required this.task});

  final String projectId;
  final ProjectTask task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phasesAsync = ref.watch(projectPhasesProvider(projectId));

    return phasesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _TaskDetailsError(
        message: error.toString(),
        onRetry: () => ref.invalidate(projectPhasesProvider(projectId)),
      ),
      data: (phases) {
        final phase = phases
            .where((item) => item.id == task.phaseId)
            .firstOrNull;

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Text(task.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              phase?.name ?? 'Unknown phase',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            _ExecutionSummaryCard(task: task),
            const SizedBox(height: AppSpacing.md),
            _TaskSection(
              title: 'Schedule',
              icon: Icons.calendar_month_outlined,
              child: Column(
                children: [
                  _DetailRow(
                    label: 'Planned',
                    value:
                        '${_formatDate(task.plannedStartDate)} - '
                        '${_formatDate(task.plannedEndDate)}',
                  ),
                  _DetailRow(label: 'Actual', value: _actualDateRange(task)),
                  _DetailRow(
                    label: 'Schedule variance',
                    value: _scheduleVariance(task),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _TaskSection(
              title: 'Task information',
              icon: Icons.info_outline,
              child: Column(
                children: [
                  _DetailRow(label: 'Status', value: _statusLabel(task.status)),
                  _DetailRow(
                    label: 'Priority',
                    value: _priorityLabel(task.priority),
                  ),
                  _DetailRow(
                    label: 'Progress',
                    value: '${task.progress.toStringAsFixed(0)}%',
                  ),
                ],
              ),
            ),
            if (task.description != null) ...[
              const SizedBox(height: AppSpacing.md),
              _TaskSection(
                title: 'Description',
                icon: Icons.description_outlined,
                child: Text(task.description!),
              ),
            ],
            if (task.notes != null) ...[
              const SizedBox(height: AppSpacing.md),
              _TaskSection(
                title: 'Execution notes',
                icon: Icons.sticky_note_2_outlined,
                child: Text(task.notes!),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            _TaskWorkersSection(task: task),
            const SizedBox(height: AppSpacing.md),
            _TaskLabourSection(task: task),
            const SizedBox(height: AppSpacing.md),
            _TaskProgressHistorySection(task: task),
            const SizedBox(height: AppSpacing.md),
            _TaskReportsSection(task: task),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: () => _updateExecution(context, ref, task),
              icon: const Icon(Icons.update),
              label: const Text('Update execution'),
            ),
          ],
        );
      },
    );
  }
}

class _TaskWorkersSection extends ConsumerWidget {
  const _TaskWorkersSection({required this.task});

  final ProjectTask task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workersAsync = ref.watch(workersProvider);

    return _TaskSection(
      title: 'Assigned workers',
      icon: Icons.groups_outlined,
      child: workersAsync.when(
        loading: () => const LinearProgressIndicator(),
        error: (error, _) => Text(
          'Unable to load workers: $error',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        data: (workers) {
          final assignedWorkers = workers
              .where((worker) => task.assignedWorkerIds.contains(worker.id))
              .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (assignedWorkers.isEmpty)
                const Text('No workers assigned yet.')
              else
                ...assignedWorkers.map(
                  (worker) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      child: Icon(Icons.person_outline),
                    ),
                    title: Text(worker.name),
                    subtitle: Text(_workerRoleLabel(worker.role)),
                    trailing: IconButton(
                      tooltip: 'Remove worker',
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => _saveWorkers(
                        context,
                        ref,
                        task,
                        task.assignedWorkerIds
                            .where((id) => id != worker.id)
                            .toList(),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.xs),
              OutlinedButton.icon(
                onPressed: () => _assignWorkers(context, ref, workers),
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Assign workers'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _assignWorkers(
    BuildContext context,
    WidgetRef ref,
    List<Worker> workers,
  ) async {
    final selectedIds = await showDialog<List<String>>(
      context: context,
      builder: (_) => _AssignWorkersDialog(
        workers: workers,
        selectedWorkerIds: task.assignedWorkerIds,
      ),
    );

    if (selectedIds == null || !context.mounted) {
      return;
    }

    await _saveWorkers(context, ref, task, selectedIds);
  }

  Future<void> _saveWorkers(
    BuildContext context,
    WidgetRef ref,
    ProjectTask task,
    List<String> workerIds,
  ) async {
    await ref
        .read(projectTaskActionsProvider)
        .updateTask(
          ProjectTask(
            id: task.id,
            projectId: task.projectId,
            phaseId: task.phaseId,
            name: task.name,
            description: task.description,
            plannedStartDate: task.plannedStartDate,
            plannedEndDate: task.plannedEndDate,
            actualStartDate: task.actualStartDate,
            actualEndDate: task.actualEndDate,
            status: task.status,
            priority: task.priority,
            progress: task.progress,
            notes: task.notes,
            assignedWorkerIds: workerIds,
            isArchived: task.isArchived,
          ),
        );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task workers updated successfully.')),
    );
  }
}

class _AssignWorkersDialog extends StatefulWidget {
  const _AssignWorkersDialog({
    required this.workers,
    required this.selectedWorkerIds,
  });

  final List<Worker> workers;
  final List<String> selectedWorkerIds;

  @override
  State<_AssignWorkersDialog> createState() => _AssignWorkersDialogState();
}

class _AssignWorkersDialogState extends State<_AssignWorkersDialog> {
  late final Set<String> _selectedWorkerIds;

  @override
  void initState() {
    super.initState();
    _selectedWorkerIds = widget.selectedWorkerIds.toSet();
  }

  @override
  Widget build(BuildContext context) {
    final activeWorkers = widget.workers
        .where((worker) => worker.isActive)
        .toList();

    return AlertDialog(
      title: const Text('Assign workers'),
      content: SizedBox(
        width: 480,
        child: activeWorkers.isEmpty
            ? const Text('No active workers are available.')
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: activeWorkers
                      .map(
                        (worker) => CheckboxListTile(
                          value: _selectedWorkerIds.contains(worker.id),
                          title: Text(worker.name),
                          subtitle: Text(_workerRoleLabel(worker.role)),
                          secondary: const Icon(Icons.person_outline),
                          onChanged: (selected) {
                            setState(() {
                              if (selected == true) {
                                _selectedWorkerIds.add(worker.id);
                              } else {
                                _selectedWorkerIds.remove(worker.id);
                              }
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(_selectedWorkerIds.toList()),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _TaskLabourSection extends ConsumerWidget {
  const _TaskLabourSection({required this.task});

  final ProjectTask task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(taskLabourSummaryProvider(task));

    return _TaskSection(
      title: 'Task-level labour',
      icon: Icons.payments_outlined,
      child: summaryAsync.when(
        loading: () => const LinearProgressIndicator(),
        error: (error, _) => Text(
          'Unable to load labour summary: $error',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        data: (summary) {
          if (task.assignedWorkerIds.isEmpty) {
            return const Text(
              'Assign workers to this task to track recorded labour.',
            );
          }

          if (summary.attendanceRecordCount == 0) {
            return const Text(
              'No attendance records found during the task window.',
            );
          }

          return Column(
            children: [
              _DetailRow(
                label: 'Attendance records',
                value: '${summary.attendanceRecordCount}',
              ),
              _DetailRow(
                label: 'Hours worked',
                value: summary.totalHoursWorked.toStringAsFixed(1),
              ),
              _DetailRow(
                label: 'Overtime hours',
                value: summary.totalOvertimeHours.toStringAsFixed(1),
              ),
              _DetailRow(
                label: 'Base labour',
                value: _formatCurrency(summary.baseLabourCost),
              ),
              _DetailRow(
                label: 'Overtime cost',
                value: _formatCurrency(summary.overtimeCost),
              ),
              const Divider(),
              _DetailRow(
                label: 'Total labour cost',
                value: _formatCurrency(summary.totalLabourCost),
              ),
              const SizedBox(height: AppSpacing.xs),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Matched by assigned worker, project, phase, and task date window.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TaskProgressHistorySection extends ConsumerWidget {
  const _TaskProgressHistorySection({required this.task});

  final ProjectTask task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updatesAsync = ref.watch(projectTaskProgressProvider(task.id));

    return _TaskSection(
      title: 'Progress history',
      icon: Icons.timeline_outlined,
      child: updatesAsync.when(
        loading: () => const LinearProgressIndicator(),
        error: (error, _) => Text(
          'Unable to load progress history: $error',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        data: (updates) {
          if (updates.isEmpty) {
            return const Text('No progress updates recorded yet.');
          }

          return Column(
            children: updates
                .map(
                  (update) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      child: Text(
                        update.progress.toStringAsFixed(0),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    title: Text(
                      '${update.progress.toStringAsFixed(0)}% - '
                      '${_statusLabel(update.status)}',
                    ),
                    subtitle: Text(
                      [
                        _formatDateTime(update.recordedAt),
                        if (update.notes != null) update.notes!,
                      ].join(' · '),
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}

class _TaskReportsSection extends ConsumerWidget {
  const _TaskReportsSection({required this.task});

  final ProjectTask task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(taskDailySiteReportsProvider(task));

    return _TaskSection(
      title: 'Daily site reports',
      icon: Icons.article_outlined,
      child: reportsAsync.when(
        loading: () => const LinearProgressIndicator(),
        error: (error, _) => Text(
          'Unable to load site reports: $error',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        data: (reports) {
          if (reports.isEmpty) {
            return const Text('No daily site reports linked to this task.');
          }

          return Column(
            children: reports
                .map(
                  (report) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.today_outlined),
                    title: Text(_formatDate(report.date)),
                    subtitle: Text(
                      report.workCompleted.isEmpty
                          ? 'No completed work recorded.'
                          : report.workCompleted,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}

Future<void> _updateExecution(
  BuildContext context,
  WidgetRef ref,
  ProjectTask task,
) async {
  final updatedTask = await showDialog<ProjectTask>(
    context: context,
    builder: (_) => _ExecutionUpdateDialog(task: task),
  );

  if (updatedTask == null || !context.mounted) {
    return;
  }

  await ref.read(projectTaskActionsProvider).updateTask(updatedTask);
  await ref
      .read(projectTaskProgressActionsProvider)
      .createUpdate(
        ProjectTaskProgressUpdate(
          id: 'task-progress-${DateTime.now().microsecondsSinceEpoch}',
          taskId: updatedTask.id,
          progress: updatedTask.progress,
          status: updatedTask.status,
          recordedAt: DateTime.now(),
          notes: updatedTask.notes,
        ),
      );

  if (!context.mounted) {
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Execution updated successfully.')),
  );
}

String _actualDateRange(ProjectTask task) {
  if (task.actualStartDate == null && task.actualEndDate == null) {
    return 'Not started';
  }

  final start = task.actualStartDate == null
      ? 'Not recorded'
      : _formatDate(task.actualStartDate!);
  final end = task.actualEndDate == null
      ? 'In progress'
      : _formatDate(task.actualEndDate!);

  return '$start - $end';
}

String _scheduleVariance(ProjectTask task) {
  if (task.actualEndDate == null) {
    final today = DateTime.now();
    if (today.isAfter(task.plannedEndDate) && task.progress < 100) {
      final days = today.difference(task.plannedEndDate).inDays;
      return 'Overdue by $days day${days == 1 ? '' : 's'}';
    }
    return 'Not available yet';
  }

  final variance = task.actualEndDate!.difference(task.plannedEndDate).inDays;
  if (variance == 0) {
    return 'On schedule';
  }
  if (variance > 0) {
    return '$variance day${variance == 1 ? '' : 's'} late';
  }
  return '${variance.abs()} day${variance.abs() == 1 ? '' : 's'} early';
}

String _formatCurrency(double value) {
  return '₹${value.toStringAsFixed(2)}';
}

class _ExecutionSummaryCard extends StatelessWidget {
  const _ExecutionSummaryCard({required this.task});

  final ProjectTask task;

  @override
  Widget build(BuildContext context) {
    final progress = (task.progress / 100).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Execution progress',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  '${task.progress.toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: AppSpacing.sm),
            Text(_statusLabel(task.status)),
          ],
        ),
      ),
    );
  }
}

class _TaskSection extends StatelessWidget {
  const _TaskSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: AppSpacing.xs),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            child,
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _ExecutionUpdateDialog extends StatefulWidget {
  const _ExecutionUpdateDialog({required this.task});

  final ProjectTask task;

  @override
  State<_ExecutionUpdateDialog> createState() => _ExecutionUpdateDialogState();
}

class _ExecutionUpdateDialogState extends State<_ExecutionUpdateDialog> {
  late ProjectTaskStatus _status;
  late DateTime? _actualStartDate;
  late DateTime? _actualEndDate;
  late final TextEditingController _progressController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _status = widget.task.status;
    _actualStartDate = widget.task.actualStartDate;
    _actualEndDate = widget.task.actualEndDate;
    _progressController = TextEditingController(
      text: widget.task.progress.toStringAsFixed(0),
    );
    _notesController = TextEditingController(text: widget.task.notes ?? '');
  }

  @override
  void dispose() {
    _progressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update execution'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<ProjectTaskStatus>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: ProjectTaskStatus.values
                    .map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(_statusLabel(status)),
                      ),
                    )
                    .toList(),
                onChanged: (status) {
                  if (status == null) return;
                  setState(() {
                    _status = status;
                    if (status == ProjectTaskStatus.completed) {
                      _progressController.text = '100';
                      _actualEndDate ??= DateTime.now();
                    }
                  });
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _ExecutionDateField(
                      label: 'Actual start',
                      date: _actualStartDate,
                      onTap: () => _selectDate(
                        current: _actualStartDate ?? DateTime.now(),
                        onSelected: (date) {
                          setState(() => _actualStartDate = date);
                        },
                      ),
                      onClear: _actualStartDate == null
                          ? null
                          : () => setState(() => _actualStartDate = null),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _ExecutionDateField(
                      label: 'Actual end',
                      date: _actualEndDate,
                      onTap: () => _selectDate(
                        current: _actualEndDate ?? DateTime.now(),
                        firstDate: _actualStartDate,
                        onSelected: (date) {
                          setState(() => _actualEndDate = date);
                        },
                      ),
                      onClear: _actualEndDate == null
                          ? null
                          : () => setState(() => _actualEndDate = null),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _progressController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Progress (%)',
                  hintText: '0 - 100',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Execution notes'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Save update')),
      ],
    );
  }

  Future<void> _selectDate({
    required DateTime current,
    DateTime? firstDate,
    required ValueChanged<DateTime> onSelected,
  }) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: firstDate ?? DateTime(2020),
      lastDate: DateTime(DateTime.now().year + 10),
    );
    if (selected != null) onSelected(selected);
  }

  void _submit() {
    final progress = double.tryParse(_progressController.text.trim());
    if (progress == null || progress < 0 || progress > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Progress must be between 0 and 100.')),
      );
      return;
    }
    if (_actualEndDate != null &&
        _actualStartDate != null &&
        _actualEndDate!.isBefore(_actualStartDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Actual end cannot be before start.')),
      );
      return;
    }
    if (_status == ProjectTaskStatus.completed && progress != 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completed tasks must be at 100%.')),
      );
      return;
    }

    Navigator.of(context).pop(
      ProjectTask(
        id: widget.task.id,
        projectId: widget.task.projectId,
        phaseId: widget.task.phaseId,
        name: widget.task.name,
        description: widget.task.description,
        plannedStartDate: widget.task.plannedStartDate,
        plannedEndDate: widget.task.plannedEndDate,
        actualStartDate: _actualStartDate,
        actualEndDate: _actualEndDate,
        status: _status,
        priority: widget.task.priority,
        progress: progress,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        assignedWorkerIds: widget.task.assignedWorkerIds,
        isArchived: widget.task.isArchived,
      ),
    );
  }
}

class _ExecutionDateField extends StatelessWidget {
  const _ExecutionDateField({
    required this.label,
    required this.date,
    required this.onTap,
    required this.onClear,
  });

  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: onClear == null
            ? null
            : IconButton(onPressed: onClear, icon: const Icon(Icons.clear)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Text(date == null ? 'Not set' : _formatDate(date!)),
      ),
    );
  }
}

class _TaskDetailsError extends StatelessWidget {
  const _TaskDetailsError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: AppSpacing.sm),
            const Text('Unable to load task details.'),
            const SizedBox(height: AppSpacing.xs),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}

String _formatDateTime(DateTime date) {
  return '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';
}

String _statusLabel(ProjectTaskStatus status) {
  switch (status) {
    case ProjectTaskStatus.notStarted:
      return 'Not Started';
    case ProjectTaskStatus.inProgress:
      return 'In Progress';
    case ProjectTaskStatus.completed:
      return 'Completed';
    case ProjectTaskStatus.delayed:
      return 'Delayed';
    case ProjectTaskStatus.onHold:
      return 'On Hold';
  }
}

String _priorityLabel(ProjectTaskPriority priority) {
  switch (priority) {
    case ProjectTaskPriority.low:
      return 'Low';
    case ProjectTaskPriority.medium:
      return 'Medium';
    case ProjectTaskPriority.high:
      return 'High';
    case ProjectTaskPriority.critical:
      return 'Critical';
  }
}

String _workerRoleLabel(WorkerRole role) {
  switch (role) {
    case WorkerRole.mason:
      return 'Mason';
    case WorkerRole.helper:
      return 'Helper';
    case WorkerRole.carpenter:
      return 'Carpenter';
    case WorkerRole.electrician:
      return 'Electrician';
    case WorkerRole.plumber:
      return 'Plumber';
    case WorkerRole.painter:
      return 'Painter';
    case WorkerRole.welder:
      return 'Welder';
    case WorkerRole.supervisor:
      return 'Supervisor';
    case WorkerRole.siteEngineer:
      return 'Site Engineer';
    case WorkerRole.other:
      return 'Other';
  }
}
