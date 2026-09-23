import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/project.dart';
import '../providers/project_providers.dart';
import '../widgets/project_form_dialog.dart';
import '../../../workforce/presentation/providers/labour_cost_summary_providers.dart';
import '../../../workforce/presentation/providers/labour_phase_cost_summary_providers.dart';
import '../../../workforce/domain/entities/labour_phase_cost_summary.dart';

class ProjectDetailsPage extends ConsumerWidget {
  const ProjectDetailsPage({
    required this.projectId,
    super.key,
  });

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(
      projectProvider(projectId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Details'),
        actions: [
          IconButton(
            onPressed: () async {
              final project = projectAsync.value;

              if (project == null) {
                return;
              }

              final updated = await showDialog<bool>(
                context: context,
                builder: (_) => ProjectFormDialog(
                  project: project,
                ),
              );

              if (updated == true) {
                ref.invalidate(projectProvider(projectId));
                ref.invalidate(projectsProvider);
              }
            },
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit project',
          ),
        ],
      ),
      body: projectAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => const Center(
          child: Text('Project not found'),
        ),
        data: (project) => _ProjectDetailsContent(
          project: project,
        ),
      ),
    );
  }
}

class _ProjectDetailsContent extends StatelessWidget {
  const _ProjectDetailsContent({
    required this.project,
  });

  final Project project;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  project.siteAddress,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _ProjectSummaryCard(
            project: project,
          ),
          const SizedBox(height: AppSpacing.lg),
          _LabourSummarySection(
            projectId: project.id,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Project Management',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          _ManagementOption(
            icon: Icons.timeline_outlined,
            title: 'Timeline',
            subtitle: 'Manage project phases and progress',
            onTap: () {
              context.push(
                '/projects/${project.id}/timeline',
              );
            },
          ),
          _ManagementOption(
            icon: Icons.contacts_outlined,
            title: 'Contacts',
            subtitle: 'Client, engineers, architects and others',
            onTap: () {
              context.push(
                '/projects/${project.id}/contacts',
              );
            },
          ),
          _ManagementOption(
            icon: Icons.request_quote_outlined,
            title: 'Quotation',
            subtitle: 'Manage quotation and commercial details',
            onTap: () {
              context.push(
                '/projects/${project.id}/quotations',
              );
            },
          ),
          _ManagementOption(
            icon: Icons.request_quote_outlined,
            title: 'Purchase Quotations',
            subtitle: 'Supplier quotations and material pricing',
            onTap: () {
              context.push(
                '/projects/${project.id}/purchase-quotations',
              );
            },
          ),
          _ManagementOption(
            icon: Icons.request_quote_outlined,
            title: 'Purchase Orders',
            subtitle: 'Manage purchase orders and supplier deliveries',
            onTap: () {
              context.push(
                '/projects/${project.id}/purchase-orders',
              );
            },
          ),
          _ManagementOption(
            icon: Icons.inventory_2_outlined,
            title: 'Material Requirements',
            subtitle: 'Plan materials required for this project',
            onTap: () {
              context.push(
                '/projects/${project.id}/material-requirements',
              );
            },
          ),
          _ManagementOption(
            icon: Icons.assignment_outlined,
            title: 'Daily Site Reports',
            subtitle: 'Record daily work, issues, safety and quality',
            onTap: () {
              context.push(
                '/projects/${project.id}/daily-site-reports',
              );
            },
          ),
          _ManagementOption(
            icon: Icons.groups_outlined,
            title: 'Labour',
            subtitle: 'Manage workers and labour assignments',
            onTap: () {
              context.push('/workers');
            },
          ),
          _ManagementOption(
            icon: Icons.inventory_2_outlined,
            title: 'Materials',
            subtitle: 'Manage the material master catalog',
            onTap: () {
              context.push('/materials');
            },
          ),
          _ManagementOption(
            icon: Icons.local_shipping_outlined,
            title: 'Suppliers',
            subtitle: 'Manage suppliers and procurement',
            onTap: () {
              context.push('/suppliers');
            },
          ),
        ],
      ),
    );
  }
}

class _LabourSummarySection extends ConsumerStatefulWidget {
  const _LabourSummarySection({
    required this.projectId,
  });

  final String projectId;

  @override
  ConsumerState<_LabourSummarySection> createState() =>
      _LabourSummarySectionState();
}

class _LabourSummarySectionState
    extends ConsumerState<_LabourSummarySection> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();

    final today = DateTime.now();

    _selectedDate = DateTime(
      today.year,
      today.month,
      today.day,
    );
  }

  @override
  Widget build(BuildContext context) {
    final filter = LabourCostSummaryFilter(
      projectId: widget.projectId,
      startDate: _selectedDate,
      endDate: _selectedDate,
    );

    final phaseFilter = LabourPhaseCostSummaryFilter(
      projectId: widget.projectId,
      startDate: _selectedDate,
      endDate: _selectedDate,
    );

    final summaryAsync = ref.watch(
      labourCostSummaryProvider(filter),
    );

    final phaseSummaryAsync = ref.watch(
      labourPhaseCostSummaryProvider(phaseFilter),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DailyLabourSummaryCard(
          selectedDate: _selectedDate,
          summaryAsync: summaryAsync,
          onSelectDate: () => _selectDate(context),
        ),
        const SizedBox(height: AppSpacing.md),
        _LabourCostByPhaseCard(
          summaryAsync: phaseSummaryAsync,
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      _selectedDate = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      );
    });
  }
}

class _DailyLabourSummaryCard extends StatelessWidget {
  const _DailyLabourSummaryCard({
    required this.selectedDate,
    required this.summaryAsync,
    required this.onSelectDate,
  });

  final DateTime selectedDate;
  final AsyncValue summaryAsync;
  final VoidCallback onSelectDate;

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
                const Icon(
                  Icons.groups_outlined,
                ),
                const SizedBox(
                  width: AppSpacing.sm,
                ),
                Expanded(
                  child: Text(
                    'Daily Labour Cost',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: onSelectDate,
                  icon: const Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                  ),
                  label: Text(
                    _formatDate(selectedDate),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.md),
            summaryAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stackTrace) => Text(
                'Unable to load labour summary.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium,
              ),
              data: (summary) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _LabourSummaryItem(
                            label: 'Workers',
                            value: '${summary.totalWorkers}',
                          ),
                        ),
                        Expanded(
                          child: _LabourSummaryItem(
                            label: 'Present',
                            value: '${summary.presentWorkers}',
                          ),
                        ),
                        Expanded(
                          child: _LabourSummaryItem(
                            label: 'Half Day',
                            value: '${summary.halfDayWorkers}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: AppSpacing.md,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _LabourSummaryItem(
                            label: 'Absent',
                            value: '${summary.absentWorkers}',
                          ),
                        ),
                        Expanded(
                          child: _LabourSummaryItem(
                            label: 'Leave',
                            value: '${summary.leaveWorkers}',
                          ),
                        ),
                        const Expanded(
                          child: SizedBox(),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: AppSpacing.md,
                    ),
                    const Divider(),
                    const SizedBox(
                      height: AppSpacing.md,
                    ),
                    _LabourCostRow(
                      label: 'Base Labour',
                      amount: summary.baseLabourCost,
                    ),
                    const SizedBox(
                      height: AppSpacing.sm,
                    ),
                    _LabourCostRow(
                      label: 'Overtime',
                      amount: summary.overtimeCost,
                    ),
                    const SizedBox(
                      height: AppSpacing.sm,
                    ),
                    const Divider(),
                    const SizedBox(
                      height: AppSpacing.sm,
                    ),
                    _LabourCostRow(
                      label: 'Total Labour Cost',
                      amount: summary.totalLabourCost,
                      isTotal: true,
                    ),
                  ],
                );
              },
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

class _LabourCostByPhaseCard extends StatelessWidget {
  const _LabourCostByPhaseCard({
    required this.summaryAsync,
  });

  final AsyncValue summaryAsync;

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
                const Icon(
                  Icons.account_tree_outlined,
                ),
                const SizedBox(
                  width: AppSpacing.sm,
                ),
                Expanded(
                  child: Text(
                    'Labour Cost by Phase',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: AppSpacing.md,
            ),
            const Divider(),
            const SizedBox(
              height: AppSpacing.md,
            ),
            summaryAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stackTrace) => Text(
                'Unable to load phase labour summary.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium,
              ),
              data: (summaries) {
                if (summaries.isEmpty) {
                  return Text(
                    'No phase-wise labour records for this date.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium,
                  );
                }

                return Column(
                  children: [
                    for (var index = 0;
                        index < summaries.length;
                        index++) ...[
                      _LabourPhaseSummaryItem(
                        summary: summaries[index],
                      ),
                      if (index < summaries.length - 1)
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                          child: Divider(),
                        ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LabourPhaseSummaryItem extends StatelessWidget {
  const _LabourPhaseSummaryItem({
    required this.summary,
  });

  final LabourPhaseCostSummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                summary.phaseName,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall,
              ),
            ),
            Text(
              '₹${summary.totalLabourCost.toStringAsFixed(2)}',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        const SizedBox(
          height: AppSpacing.sm,
        ),
        Row(
          children: [
            Expanded(
              child: _LabourSummaryItem(
                label: 'Workers',
                value: '${summary.workerCount}',
              ),
            ),
            Expanded(
              child: _LabourSummaryItem(
                label: 'Present',
                value: '${summary.presentWorkers}',
              ),
            ),
            Expanded(
              child: _LabourSummaryItem(
                label: 'Half Day',
                value: '${summary.halfDayWorkers}',
              ),
            ),
          ],
        ),
        const SizedBox(
          height: AppSpacing.sm,
        ),
        _LabourCostRow(
          label: 'Base Labour',
          amount: summary.baseLabourCost,
        ),
        const SizedBox(
          height: AppSpacing.xs,
        ),
        _LabourCostRow(
          label: 'Overtime',
          amount: summary.overtimeCost,
        ),
      ],
    );
  }
}

class _LabourSummaryItem extends StatelessWidget {
  const _LabourSummaryItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(
          height: AppSpacing.xxs,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

class _LabourCostRow extends StatelessWidget {
  const _LabourCostRow({
    required this.label,
    required this.amount,
    this.isTotal = false,
  });

  final String label;
  final double amount;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final textStyle = isTotal
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyMedium;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: textStyle,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: isTotal
              ? textStyle?.copyWith(
                  fontWeight: FontWeight.w700,
                )
              : textStyle,
        ),
      ],
    );
  }
}

class _ProjectSummaryCard extends StatelessWidget {
  const _ProjectSummaryCard({
    required this.project,
  });

  final Project project;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _SummaryItem(
                    label: 'Status',
                    value: _statusLabel(project.status),
                  ),
                ),
                Expanded(
                  child: _SummaryItem(
                    label: 'Budget',
                    value: _formatCurrency(project.budget),
                  ),
                ),
              ],
            ),
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
                  child: _SummaryItem(
                    label: 'Start Date',
                    value: _formatDate(project.startDate),
                  ),
                ),
                Expanded(
                  child: _SummaryItem(
                    label: 'Expected End',
                    value: project.expectedEndDate == null
                        ? '-'
                        : _formatDate(
                            project.expectedEndDate!,
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(ProjectStatus status) {
    return switch (status) {
      ProjectStatus.planning => 'Planning',
      ProjectStatus.active => 'Active',
      ProjectStatus.onHold => 'On Hold',
      ProjectStatus.completed => 'Completed',
      ProjectStatus.cancelled => 'Cancelled',
    };
  }

  String _formatCurrency(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(2)} Cr';
    }

    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(2)} L';
    }

    return '₹${amount.toStringAsFixed(0)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(
          height: AppSpacing.xxs,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _ManagementOption extends StatelessWidget {
  const _ManagementOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: AppSpacing.sm,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(
                icon,
                size: 28,
                color: Theme.of(context)
                    .colorScheme
                    .primary,
              ),
              const SizedBox(
                width: AppSpacing.md,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge,
                    ),
                    const SizedBox(
                      height: AppSpacing.xxs,
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
              ),
            ],
          ),
        ),
      ),
    );
  }
}