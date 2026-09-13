import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/project.dart';
import '../providers/project_providers.dart';

class ProjectsPage extends ConsumerWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add),
            tooltip: 'Create project',
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: projectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: AppSpacing.md),
                const Text('Unable to load projects.'),
                const SizedBox(height: AppSpacing.sm),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(projectsProvider);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (projects) {
          if (projects.isEmpty) {
            return const _EmptyProjectsView();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(projectsProvider);
              await ref.read(projectsProvider.future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: projects.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                return _ProjectCard(project: projects[index]);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('New Project'),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          context.push('/projects/${project.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _StatusBadge(status: project.status),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 18),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      project.siteAddress,
                      style: Theme.of(context).textTheme.bodySmall,
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
                    child: _ProjectMetric(
                      label: 'Budget',
                      value: _formatCurrency(project.budget),
                    ),
                  ),
                  Expanded(
                    child: _ProjectMetric(
                      label: 'Start Date',
                      value: _formatDate(project.startDate),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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

class _ProjectMetric extends StatelessWidget {
  const _ProjectMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: AppSpacing.xxs),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ProjectStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, icon) = switch (status) {
      ProjectStatus.planning => ('Planning', Icons.edit_note_outlined),
      ProjectStatus.active => ('Active', Icons.play_circle_outline),
      ProjectStatus.onHold => ('On Hold', Icons.pause_circle_outline),
      ProjectStatus.completed => ('Completed', Icons.check_circle_outline),
      ProjectStatus.cancelled => ('Cancelled', Icons.cancel_outlined),
    };

    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _EmptyProjectsView extends StatelessWidget {
  const _EmptyProjectsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.domain_add_outlined, size: 56),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No projects yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Create your first project to start managing '
              'construction operations.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
