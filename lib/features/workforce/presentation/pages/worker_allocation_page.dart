import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../domain/entities/worker_allocation.dart';
import '../../domain/usecases/manage_worker_allocation.dart';
import '../providers/worker_allocation_providers.dart';
import '../widgets/worker_allocation_form_dialog.dart';

class WorkerAllocationPage extends ConsumerWidget {
  const WorkerAllocationPage({
    super.key,
    required this.workerId,
    required this.workerName,
  });

  final String workerId;
  final String workerName;

  Future<void> _addAllocation(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final allocation =
        await showDialog<WorkerAllocation>(
      context: context,
      builder: (_) => WorkerAllocationFormDialog(
        workerId: workerId,
      ),
    );

    if (allocation == null) {
      return;
    }

    final repository =
        ref.read(workerAllocationRepositoryProvider);

    await ManageWorkerAllocation(repository)
        .create(allocation);

    ref.invalidate(
      workerAllocationsProvider(workerId),
    );
  }

  Future<void> _editAllocation(
    BuildContext context,
    WidgetRef ref,
    WorkerAllocation allocation,
  ) async {
    final updatedAllocation =
        await showDialog<WorkerAllocation>(
      context: context,
      builder: (_) => WorkerAllocationFormDialog(
        workerId: workerId,
        allocation: allocation,
      ),
    );

    if (updatedAllocation == null) {
      return;
    }

    final repository =
        ref.read(workerAllocationRepositoryProvider);

    await ManageWorkerAllocation(repository)
        .update(updatedAllocation);

    ref.invalidate(
      workerAllocationsProvider(workerId),
    );
  }

  Future<void> _deleteAllocation(
    BuildContext context,
    WidgetRef ref,
    WorkerAllocation allocation,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Allocation?'),
          content: Text(
            'Remove "${allocation.workDescription}" '
            'from this worker\'s allocation plan?',
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

    if (shouldDelete != true) {
      return;
    }

    final repository =
        ref.read(workerAllocationRepositoryProvider);

    await ManageWorkerAllocation(repository)
        .delete(allocation.id);

    ref.invalidate(
      workerAllocationsProvider(workerId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allocationsAsync =
        ref.watch(workerAllocationsProvider(workerId));

    final projectsAsync = ref.watch(projectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('$workerName - Allocation'),
      ),
      body: allocationsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => const Center(
          child: Text(
            'Unable to load allocations',
          ),
        ),
        data: (allocations) {
          if (allocations.isEmpty) {
            return const _EmptyAllocationState();
          }

          final sortedAllocations =
              [...allocations]
                ..sort(
                  (a, b) => b.date.compareTo(a.date),
                );

          return ListView.separated(
            padding: const EdgeInsets.all(
              AppSpacing.md,
            ),
            itemCount: sortedAllocations.length,
            separatorBuilder: (_, _) =>
                const SizedBox(
              height: AppSpacing.sm,
            ),
            itemBuilder: (context, index) {
              final allocation =
                  sortedAllocations[index];

              return _AllocationCard(
                allocation: allocation,
                projectName: projectsAsync.maybeWhen(
                  data: (projects) {
                    for (final project in projects) {
                      if (project.id ==
                          allocation.projectId) {
                        return project.name;
                      }
                    }

                    return 'Unknown Project';
                  },
                  orElse: () => 'Loading...',
                ),
                onEdit: () {
                  _editAllocation(
                    context,
                    ref,
                    allocation,
                  );
                },
                onDelete: () {
                  _deleteAllocation(
                    context,
                    ref,
                    allocation,
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () {
          _addAllocation(context, ref);
        },
        icon: const Icon(
          Icons.assignment_outlined,
        ),
        label: const Text('Add Allocation'),
      ),
    );
  }
}

class _AllocationCard extends StatelessWidget {
  const _AllocationCard({
    required this.allocation,
    required this.projectName,
    required this.onEdit,
    required this.onDelete,
  });

  final WorkerAllocation allocation;
  final String projectName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
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
              children: [
                Expanded(
                  child: Text(
                    _formatDate(allocation.date),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium,
                  ),
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons.edit_outlined,
                  ),
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline,
                  ),
                  tooltip: 'Delete',
                ),
              ],
            ),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            Text(
              allocation.workDescription,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge,
            ),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            _AllocationInfoRow(
              icon: Icons.business_outlined,
              text: projectName,
            ),
            const SizedBox(
              height: AppSpacing.xs,
            ),
            _AllocationInfoRow(
              icon: Icons.schedule_outlined,
              text:
                  '${allocation.plannedHours} planned hours',
            ),
            if (allocation.notes != null) ...[
              const SizedBox(
                height: AppSpacing.sm,
              ),
              Text(
                allocation.notes!,
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _AllocationInfoRow extends StatelessWidget {
  const _AllocationInfoRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context)
              .colorScheme
              .primary,
        ),
        const SizedBox(
          width: AppSpacing.sm,
        ),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context)
                .textTheme
                .bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _EmptyAllocationState
    extends StatelessWidget {
  const _EmptyAllocationState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 56,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),
            const SizedBox(
              height: AppSpacing.md,
            ),
            Text(
              'No allocations yet',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge,
            ),
            const SizedBox(
              height: AppSpacing.xs,
            ),
            Text(
              'Plan the work assigned to this '
              'worker for each day.',
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