import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/project.dart';
import '../providers/project_providers.dart';

class ProjectsPage extends ConsumerWidget {
  const ProjectsPage({super.key});

  Future<void> _showAddProjectDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final created = await showDialog<bool>(
      context: context,
      builder: (_) => const _AddProjectDialog(),
    );

    if (created == true) {
      ref.invalidate(projectsProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          IconButton(
            onPressed: () => _showAddProjectDialog(context, ref),
            icon: const Icon(Icons.add),
            tooltip: 'Create project',
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: projectsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
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
              separatorBuilder: (_, _) => const SizedBox(
                height: AppSpacing.sm,
              ),
              itemBuilder: (context, index) {
                return _ProjectCard(
                  project: projects[index],
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProjectDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Project'),
      ),
    );
  }
}

class _AddProjectDialog extends ConsumerStatefulWidget {
  const _AddProjectDialog();

  @override
  ConsumerState<_AddProjectDialog> createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends ConsumerState<_AddProjectDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _clientIdController = TextEditingController();
  final _addressController = TextEditingController();
  final _budgetController = TextEditingController();

  ProjectStatus _status = ProjectStatus.planning;
  DateTime _startDate = DateTime.now();
  DateTime? _expectedEndDate;

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _clientIdController.dispose();
    _addressController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selected != null) {
      setState(() {
        _startDate = selected;

        if (_expectedEndDate != null &&
            _expectedEndDate!.isBefore(_startDate)) {
          _expectedEndDate = null;
        }
      });
    }
  }

  Future<void> _selectExpectedEndDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _expectedEndDate ?? _startDate,
      firstDate: _startDate,
      lastDate: DateTime(2100),
    );

    if (selected != null) {
      setState(() {
        _expectedEndDate = selected;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final repository = ref.read(projectRepositoryProvider);

      final budget =
          double.tryParse(_budgetController.text.trim()) ?? 0;

      final project = Project(
        id: 'project-${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        clientId: _clientIdController.text.trim(),
        siteAddress: _addressController.text.trim(),
        status: _status,
        startDate: _startDate,
        expectedEndDate: _expectedEndDate,
        budget: budget,
      );

      await repository.createProject(project);

      if (!mounted) return;

      Navigator.of(context).pop(true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Project created successfully.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to create project: $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Project'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Project Name',
                    hintText: 'e.g. Residential Villa',
                    prefixIcon: Icon(Icons.business_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter a project name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                TextFormField(
                  controller: _clientIdController,
                  decoration: const InputDecoration(
                    labelText: 'Client ID',
                    hintText: 'e.g. client-003',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter the client ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                TextFormField(
                  controller: _addressController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Site Address',
                    hintText: 'e.g. Velachery, Chennai',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter the site address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                DropdownButtonFormField<ProjectStatus>(
                  initialValue: _status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    prefixIcon: Icon(Icons.flag_outlined),
                  ),
                  items: ProjectStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(_statusLabel(status)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _status = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                TextFormField(
                  controller: _budgetController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Budget',
                    hintText: 'e.g. 8500000',
                    prefixText: '₹ ',
                    prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter the project budget';
                    }

                    final budget = double.tryParse(value.trim());

                    if (budget == null || budget < 0) {
                      return 'Enter a valid budget';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: const Text('Start Date'),
                  subtitle: Text(_formatDate(_startDate)),
                  trailing: TextButton(
                    onPressed: _selectStartDate,
                    child: const Text('Change'),
                  ),
                ),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_outlined),
                  title: const Text('Expected End Date'),
                  subtitle: Text(
                    _expectedEndDate == null
                        ? 'Not set'
                        : _formatDate(_expectedEndDate!),
                  ),
                  trailing: TextButton(
                    onPressed: _selectExpectedEndDate,
                    child: const Text('Change'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _isSaving ? null : _saveProject,
          icon: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.save_outlined),
          label: Text(_isSaving ? 'Saving...' : 'Save Project'),
        ),
      ],
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
  const _ProjectMetric({
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ProjectStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, icon) = switch (status) {
      ProjectStatus.planning => (
          'Planning',
          Icons.edit_note_outlined,
        ),
      ProjectStatus.active => (
          'Active',
          Icons.play_circle_outline,
        ),
      ProjectStatus.onHold => (
          'On Hold',
          Icons.pause_circle_outline,
        ),
      ProjectStatus.completed => (
          'Completed',
          Icons.check_circle_outline,
        ),
      ProjectStatus.cancelled => (
          'Cancelled',
          Icons.cancel_outlined,
        ),
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
