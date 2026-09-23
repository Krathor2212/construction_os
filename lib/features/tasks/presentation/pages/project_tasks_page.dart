import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../projects/domain/entities/project_phase.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../providers/project_task_providers.dart';
import '../../domain/entities/project_task.dart';
import '../widgets/project_task_form_dialog.dart';


class ProjectTasksPage extends ConsumerWidget {
  const ProjectTasksPage({
    super.key,
    required this.projectId,
  });

  final String projectId;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final tasksAsync = ref.watch(
      projectTasksProvider(projectId),
    );

    final phasesAsync = ref.watch(
      projectPhasesProvider(projectId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      floatingActionButton: FloatingActionButton.extended(
      onPressed: () async {
        final task = await showDialog<ProjectTask>(
          context: context,
          builder: (_) => ProjectTaskFormDialog(
            projectId: projectId,
          ),
        );

        if (task == null || !context.mounted) {
          return;
        }

        final taskWithId = ProjectTask(
          id: 'task-${DateTime.now().microsecondsSinceEpoch}',
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
          isArchived: task.isArchived,
        );

        await ref
            .read(projectTaskActionsProvider)
            .createTask(taskWithId);

        if (!context.mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task created successfully.'),
          ),
        );
      },
      icon: const Icon(Icons.add),
      label: const Text('Add Task'),
    ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(
            projectTasksProvider(projectId),
          );
          await ref.read(
            projectTasksProvider(projectId).future,
          );
        },
        child: tasksAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stackTrace) => _ErrorState(
            message: error.toString(),
            onRetry: () {
              ref.invalidate(
                projectTasksProvider(projectId),
              );
            },
          ),
          data: (tasks) {
            if (tasks.isEmpty) {
              return const _EmptyState();
            }

            return phasesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => _ErrorState(
                message: error.toString(),
                onRetry: () {
                  ref.invalidate(
                    projectPhasesProvider(projectId),
                  );
                },
              ),
              data: (phases) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];

                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: _TaskCard(
                        task: task,
                        phaseName: _phaseName(
                          phases,
                          task.phaseId,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _phaseName(
    List<ProjectPhase> phases,
    String phaseId,
  ) {
    for (final phase in phases) {
      if (phase.id == phaseId) {
        return phase.name;
      }
    }

    return 'Unknown Phase';
  }
}

class _TaskCard extends ConsumerWidget {
  const _TaskCard({
    required this.task,
    required this.phaseName,
  });

  final ProjectTask task;
  final String phaseName;

  @override
  Widget build(BuildContext context,
    WidgetRef ref,) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  task.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Edit Task',
                visualDensity: VisualDensity.compact,
                onPressed: () async {
                  final updatedTask =
                      await showDialog<ProjectTask>(
                    context: context,
                    builder: (_) => ProjectTaskFormDialog(
                      projectId: task.projectId,
                      task: task,
                    ),
                  );

                  if (updatedTask == null ||
                      !context.mounted) {
                    return;
                  }

                  await ref
                      .read(projectTaskActionsProvider)
                      .updateTask(updatedTask);

                  if (!context.mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Task updated successfully.',
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 20,
                ),
              ),
              IconButton(
                tooltip: 'Archive Task',
                visualDensity: VisualDensity.compact,
                onPressed: () async {
                  final shouldArchive =
                      await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) {
                      return AlertDialog(
                        title: const Text('Archive Task?'),
                        content: Text(
                          'Archive "${task.name}"? '
                          'The task will be removed from the active task list.',
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
                            child: const Text('Archive'),
                          ),
                        ],
                      );
                    },
                  );

                  if (shouldArchive != true ||
                      !context.mounted) {
                    return;
                  }

                  await ref
                      .read(projectTaskActionsProvider)
                      .archiveTask(task);

                  if (!context.mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Task archived successfully.',
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.archive_outlined,
                  size: 20,
                ),
              ),
            ],
          ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.layers_outlined,
                  size: 17,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    phaseName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (task.progress / 100).clamp(0.0, 1.0),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  '${task.progress.toStringAsFixed(0)}% complete',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall,
                ),
                const Spacer(),
                _PriorityLabel(
                  priority: task.priority,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  '${_formatDate(task.plannedStartDate)}'
                  ' – '
                  '${_formatDate(task.plannedEndDate)}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _PriorityLabel extends StatelessWidget {
  const _PriorityLabel({
    required this.priority,
  });

  final ProjectTaskPriority priority;

  @override
  Widget build(BuildContext context) {
    return Text(
      _priorityLabel(priority),
      style: Theme.of(context)
          .textTheme
          .bodySmall
          ?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
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
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 180),
        Icon(
          Icons.task_alt,
          size: 56,
        ),
        SizedBox(height: 16),
        Center(
          child: Text(
            'No tasks found.',
          ),
        ),
      ],
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
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 120),
        const Icon(
          Icons.error_outline,
          size: 48,
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'Unable to load tasks.',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Center(
          child: OutlinedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ),
      ],
    );
  }
}