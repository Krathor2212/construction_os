import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/material_requirement.dart';
import '../providers/material_providers.dart';
import '../providers/material_requirement_procurement_providers.dart';
import '../providers/material_requirement_providers.dart';
import '../widgets/material_requirement_form_dialog.dart';
import '../widgets/material_requirement_procurement_form_dialog.dart';
import '../../domain/entities/material_requirement_procurement.dart';

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
    final requirement = await showDialog<MaterialRequirement>(
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
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
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
            children: const [
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
                style: Theme.of(context)
                    .textTheme
                    .titleMedium,
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

  Future<void> _addProcurement(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final procurement =
        await showDialog<MaterialRequirementProcurement>(
      context: context,
      builder: (_) =>
          MaterialRequirementProcurementFormDialog(
        materialRequirementId: requirement.id,
        projectId: requirement.projectId,
      ),
    );

    if (procurement == null) {
      return;
    }

    final repository = ref.read(
      materialRequirementProcurementRepositoryProvider,
    );

    await repository.createProcurement(procurement);

    ref.invalidate(
      materialRequirementProcurementsProvider(
        requirement.id,
      ),
    );

    ref.invalidate(
      materialRequirementProcurementSummaryProvider(
        requirement.id,
      ),
    );
  }

  Future<void> _editProcurement(
    BuildContext context,
    WidgetRef ref,
    MaterialRequirementProcurement procurement,
  ) async {
    final updatedProcurement =
        await showDialog<MaterialRequirementProcurement>(
      context: context,
      builder: (_) =>
          MaterialRequirementProcurementFormDialog(
        materialRequirementId: requirement.id,
        projectId: requirement.projectId,
        procurement: procurement,
      ),
    );

    if (updatedProcurement == null) {
      return;
    }

    final repository = ref.read(
      materialRequirementProcurementRepositoryProvider,
    );

    await repository.updateProcurement(
      updatedProcurement,
    );

    ref.invalidate(
      materialRequirementProcurementsProvider(
        requirement.id,
      ),
    );

    ref.invalidate(
      materialRequirementProcurementSummaryProvider(
        requirement.id,
      ),
    );
  }

  Future<void> _deleteProcurement(
    BuildContext context,
    WidgetRef ref,
    MaterialRequirementProcurement procurement,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Procurement'),
          content: const Text(
            'Are you sure you want to delete this procurement record?',
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
      materialRequirementProcurementRepositoryProvider,
    );

    await repository.deleteProcurement(
      procurement.id,
    );

    ref.invalidate(
      materialRequirementProcurementsProvider(
        requirement.id,
      ),
    );

    ref.invalidate(
      materialRequirementProcurementSummaryProvider(
        requirement.id,
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final materialAsync =
        ref.watch(materialProvider(requirement.materialId));

    final materialName = materialAsync.when(
      loading: () => 'Loading material...',
      error: (_, _) => requirement.materialId,
      data: (material) => material.name,
    );

    final summaryAsync = ref.watch(
      materialRequirementProcurementSummaryProvider(
        requirement.id,
      ),
    );

    final procurementsAsync = ref.watch(
      materialRequirementProcurementsProvider(
        requirement.id,
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
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

            const Divider(height: 24),

            Row(
              children: [
                Expanded(
                  child: Text(
                    'Procurement',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _addProcurement(
                    context,
                    ref,
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                ),
              ],
            ),

            const SizedBox(height: 8),

            summaryAsync.when(
              loading: () => const Padding(
                padding:
                    EdgeInsets.symmetric(vertical: 8),
                child: LinearProgressIndicator(),
              ),
              error: (_, _) => Text(
                'Procurement data unavailable.',
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .error,
                ),
              ),
              data: (summary) {
                return Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _ProcurementValue(
                            label: 'Required',
                            value:
                                '${summary.requiredQuantity} '
                                '${requirement.unit}',
                          ),
                        ),
                        Expanded(
                          child: _ProcurementValue(
                            label: 'Procured',
                            value:
                                '${summary.procuredQuantity} '
                                '${requirement.unit}',
                          ),
                        ),
                        Expanded(
                          child: _ProcurementValue(
                            label: 'Remaining',
                            value:
                                '${summary.remainingQuantity} '
                                '${requirement.unit}',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    LinearProgressIndicator(
                      value:
                          summary.procurementPercentage,
                    ),

                    const SizedBox(height: 6),

                    Text(
                      '${(summary.procurementPercentage * 100).toStringAsFixed(0)}% procured',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),

            procurementsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (procurements) {
                if (procurements.isEmpty) {
                  return Text(
                    'No procurement records yet.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall,
                  );
                }

                return Column(
                  children: procurements.map(
                    (procurement) {
                      return ListTile(
                        contentPadding:
                            EdgeInsets.zero,
                        leading: const Icon(
                          Icons.local_shipping_outlined,
                        ),
                        title: Text(
                          procurement.purchaseOrderId,
                        ),
                        subtitle: Text(
                          '${procurement.quantity} '
                          '${requirement.unit}'
                          '${procurement.notes != null && procurement.notes!.isNotEmpty ? '\n${procurement.notes}' : ''}',
                        ),
                        isThreeLine:
                            procurement.notes != null &&
                                procurement.notes!.isNotEmpty,
                        trailing:
                            PopupMenuButton<String>(
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                _editProcurement(
                                  context,
                                  ref,
                                  procurement,
                                );
                                break;
                              case 'delete':
                                _deleteProcurement(
                                  context,
                                  ref,
                                  procurement,
                                );
                                break;
                            }
                          },
                          itemBuilder: (context) =>
                              const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                  ).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatStatus(
    MaterialRequirementStatus status,
  ) {
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

class _ProcurementValue extends StatelessWidget {
  const _ProcurementValue({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

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
              .bodySmall,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
  
