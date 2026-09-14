import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/project.dart';
import '../providers/project_providers.dart';

class ProjectFormDialog extends ConsumerStatefulWidget {
  const ProjectFormDialog({
    this.project,
    super.key,
  });

  final Project? project;

  bool get isEditing => project != null;

  @override
  ConsumerState<ProjectFormDialog> createState() =>
      _ProjectFormDialogState();
}

class _ProjectFormDialogState
    extends ConsumerState<ProjectFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _clientIdController;
  late final TextEditingController _addressController;
  late final TextEditingController _budgetController;

  late ProjectStatus _status;
  late DateTime _startDate;
  DateTime? _expectedEndDate;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final project = widget.project;

    _nameController = TextEditingController(
      text: project?.name ?? '',
    );
    _clientIdController = TextEditingController(
      text: project?.clientId ?? '',
    );
    _addressController = TextEditingController(
      text: project?.siteAddress ?? '',
    );
    _budgetController = TextEditingController(
      text: project == null
          ? ''
          : project.budget.toStringAsFixed(0),
    );

    _status = project?.status ?? ProjectStatus.planning;
    _startDate = project?.startDate ?? DateTime.now();
    _expectedEndDate = project?.expectedEndDate;
  }

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
        id: widget.project?.id ??
            'project-${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        clientId: _clientIdController.text.trim(),
        siteAddress: _addressController.text.trim(),
        status: _status,
        startDate: _startDate,
        expectedEndDate: _expectedEndDate,
        budget: budget,
      );

      if (widget.isEditing) {
        await repository.updateProject(project);
      } else {
        await repository.createProject(project);
      }

      if (!mounted) return;

      Navigator.of(context).pop(true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Project updated successfully.'
                : 'Project created successfully.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Unable to update project: $error'
                : 'Unable to create project: $error',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEditing
        ? 'Edit Project'
        : 'Create Project';

    final saveLabel = widget.isEditing
        ? 'Update Project'
        : 'Save Project';

    return AlertDialog(
      title: Text(title),
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
                    if (value == null ||
                        value.trim().isEmpty) {
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
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Enter the client ID';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.md),

                TextFormField(
                  controller: _addressController,
                  textCapitalization:
                      TextCapitalization.sentences,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Site Address',
                    hintText: 'e.g. Velachery, Chennai',
                    prefixIcon: Icon(
                      Icons.location_on_outlined,
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
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
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Budget',
                    hintText: 'e.g. 8500000',
                    prefixText: '₹ ',
                    prefixIcon: Icon(
                      Icons.account_balance_wallet_outlined,
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Enter the project budget';
                    }

                    final budget =
                        double.tryParse(value.trim());

                    if (budget == null || budget < 0) {
                      return 'Enter a valid budget';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.md),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.calendar_today_outlined,
                  ),
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
          label: Text(
            _isSaving ? 'Saving...' : saveLabel,
          ),
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}