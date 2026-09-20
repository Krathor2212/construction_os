import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/material_requirement.dart';
import '../providers/material_providers.dart';
import '../providers/material_requirement_providers.dart';
import '../widgets/material_requirement_form_dialog.dart';

class MaterialRequirementsPage extends ConsumerWidget {
  const MaterialRequirementsPage({
    super.key,
    required this.projectId,
  });

  final String projectId;

  Future<void> _addRequirement(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final requirement =
        await showDialog<MaterialRequirement>(
      context: context,
      builder: (_) => MaterialRequirementFormDialog(
        projectId: projectId,
      ),
    );

    if (requirement == null) {
      return;
    }

    final repository =
        ref.read(materialRequirementRepositoryProvider);

    await repository.createRequirement(requirement);

    ref.invalidate(materialRequirementsProvider(projectId));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Material requirement added.'),
        ),
      );
    }
  }

  Future<void> _editRequirement(
    BuildContext context,
    WidgetRef ref,
    MaterialRequirement requirement,
  ) async {
    final updatedRequirement =
        await showDialog<MaterialRequirement>(
      context: context,
      builder: (_) => MaterialRequirementFormDialog(
        projectId: projectId,
        requirement: requirement,
      ),
    );

    if (updatedRequirement == null) {
      return;
    }

    final repository =
        ref.read(materialRequirementRepositoryProvider);

    await repository.updateRequirement(updatedRequirement);

    ref.invalidate(materialRequirementsProvider(projectId));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Material requirement updated.'),
        ),
      );
    }
  }

  Future<void> _archiveRequirement(
    BuildContext context,
    WidgetRef ref,
    MaterialRequirement requirement,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Archive Requirement'),
          content: const Text(
            'Are you sure you want to archive this material requirement?',
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

    if (confirmed != true) {
      return;
    }

    final repository =
        ref.read(materialRequirementRepositoryProvider);

    await repository.archiveRequirement(requirement.id);

    ref.invalidate(materialRequirementsProvider(projectId));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Material requirement archived.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requirementsAsync =
        ref.watch(materialRequirementsProvider(projectId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Material Requirements'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(
            materialRequirementsProvider(projectId),
          );

          await ref.read(
            materialRequirementsProvider(projectId).future,
          );
        },
        child: requirementsAsync.when(
          loading: () => ListView(
            children: [
              SizedBox(
                height: 300,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          ),
          error: (error, stackTrace) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Unable to load material requirements.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(error.toString()),
            ],
          ),
          data: (requirements) {
            if (requirements.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 100),
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'No material requirements yet.',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Add the materials required for this project.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium,
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: requirements.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final requirement = requirements[index];

                return _RequirementCard(
                  requirement: requirement,
                  onEdit: () => _editRequirement(
                    context,
                    ref,
                    requirement,
                  ),
                  onArchive: () => _archiveRequirement(
                    context,
                    ref,
                    requirement,
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addRequirement(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Requirement'),
      ),
    );
  }
}

class _RequirementCard extends ConsumerWidget {
  const _RequirementCard({
    required this.requirement,
    required this.onEdit,
    required this.onArchive,
  });

  final MaterialRequirement requirement;
  final VoidCallback onEdit;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materialAsync =
        ref.watch(materialProvider(requirement.materialId));

    final materialName = materialAsync.when(
      loading: () => 'Loading material...',
      error: (_, _) => requirement.materialId,
      data: (material) => material.name,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    materialName,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit();
                        break;
                      case 'archive':
                        onArchive();
                        break;
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    PopupMenuItem(
                      value: 'archive',
                      child: Text('Archive'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${requirement.quantity} ${requirement.unit}',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text(
                    _formatStatus(requirement.status),
                  ),
                ),
                if (requirement.requiredByDate != null)
                  Chip(
                    avatar: const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                    ),
                    label: Text(
                      'Required by '
                      '${_formatDate(requirement.requiredByDate!)}',
                    ),
                  ),
              ],
            ),
            if (requirement.phaseId != null) ...[
              const SizedBox(height: 8),
              Text(
                'Phase: ${requirement.phaseId}',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium,
              ),
            ],
            if (requirement.notes != null &&
                requirement.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                requirement.notes!,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatStatus(MaterialRequirementStatus status) {
    switch (status) {
      case MaterialRequirementStatus.planned:
        return 'Planned';
      case MaterialRequirementStatus.partiallyProcured:
        return 'Partially Procured';
      case MaterialRequirementStatus.procured:
        return 'Procured';
      case MaterialRequirementStatus.completed:
        return 'Completed';
      case MaterialRequirementStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}