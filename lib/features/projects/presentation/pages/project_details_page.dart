import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/project.dart';
import '../providers/project_providers.dart';
import '../widgets/project_form_dialog.dart';

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
                final updated = await showDialog<bool>(
                  context: context,
                  builder: (_) => ProjectFormDialog(
                    project: projectAsync.value!,
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

          _ProjectSummaryCard(project: project),

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
            context.push('/projects/${project.id}/timeline');
          },
          ),
          _ManagementOption(
            icon: Icons.contacts_outlined,
            title: 'Contacts',
            subtitle: 'Client, engineers, architects and others',
            onTap: () {
              context.push('/projects/${project.id}/contacts');
            },
          ),
          _ManagementOption(
            icon: Icons.request_quote_outlined,
            title: 'Quotation',
            subtitle: 'Manage quotation and commercial details',
            onTap: () {
              context.push('/projects/${project.id}/quotations');
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
            subtitle: 'Track material requirements and quantities',
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
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.md),
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
                        : _formatDate(project.expectedEndDate!),
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
        const SizedBox(height: AppSpacing.xxs),
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
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
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
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}