import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../projects/presentation/providers/project_providers.dart';
import '../../domain/entities/project_task.dart';

class ProjectTaskFormDialog extends ConsumerStatefulWidget {
  const ProjectTaskFormDialog({
    super.key,
    required this.projectId,
    this.task,
  });

  final String projectId;
  final ProjectTask? task;

  @override
  ConsumerState<ProjectTaskFormDialog> createState() =>
      _ProjectTaskFormDialogState();
}

class _ProjectTaskFormDialogState
    extends ConsumerState<ProjectTaskFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _progressController;
  late final TextEditingController _notesController;

  late DateTime _plannedStartDate;
  late DateTime _plannedEndDate;

  String? _phaseId;
  late ProjectTaskStatus _status;
  late ProjectTaskPriority _priority;

  @override
  void initState() {
    super.initState();

    final task = widget.task;

    _nameController = TextEditingController(
      text: task?.name ?? '',
    );

    _descriptionController = TextEditingController(
      text: task?.description ?? '',
    );

    _progressController = TextEditingController(
      text: (task?.progress ?? 0).toStringAsFixed(0),
    );

    _notesController = TextEditingController(
      text: task?.notes ?? '',
    );

    _plannedStartDate =
        task?.plannedStartDate ?? DateTime.now();

    _plannedEndDate =
        task?.plannedEndDate ??
        DateTime.now().add(
          const Duration(days: 1),
        );

    _phaseId = task?.phaseId;

    _status =
        task?.status ?? ProjectTaskStatus.notStarted;

    _priority =
        task?.priority ?? ProjectTaskPriority.medium;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _progressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phasesAsync = ref.watch(
      projectPhasesProvider(widget.projectId),
    );

    return AlertDialog(
      title: Text(
        widget.task == null
            ? 'Add Task'
            : 'Edit Task',
      ),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Task Name',
                    hintText: 'e.g. Foundation excavation',
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Enter a task name.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText:
                        'Describe the work to be completed.',
                  ),
                ),
                const SizedBox(height: 16),
                phasesAsync.when(
                  loading: () => const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                      ),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, stackTrace) =>
                      Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Unable to load phases.',
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .error,
                      ),
                    ),
                  ),
                  data: (phases) {
                    final activePhases = phases
                        .where(
                          (phase) =>
                              !phase.isArchived,
                        )
                        .toList();

                    if (_phaseId != null &&
                        !activePhases.any(
                          (phase) =>
                              phase.id == _phaseId,
                        )) {
                      _phaseId = null;
                    }

                    return DropdownButtonFormField<String>(
                      initialValue: _phaseId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Phase',
                      ),
                      items: activePhases.map(
                        (phase) {
                          return DropdownMenuItem<String>(
                            value: phase.id,
                            child: Text(
                              phase.name,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                            ),
                          );
                        },
                      ).toList(),
                      onChanged: (value) {
                        setState(() {
                          _phaseId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return 'Select a phase.';
                        }

                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _DateField(
                        label: 'Planned Start',
                        date: _plannedStartDate,
                        onTap: () =>
                            _selectDate(
                          initialDate:
                              _plannedStartDate,
                          onSelected: (date) {
                            setState(() {
                              _plannedStartDate =
                                  date;

                              if (_plannedEndDate
                                  .isBefore(date)) {
                                _plannedEndDate =
                                    date;
                              }
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DateField(
                        label: 'Planned End',
                        date: _plannedEndDate,
                        onTap: () =>
                            _selectDate(
                          initialDate:
                              _plannedEndDate,
                          firstDate:
                              _plannedStartDate,
                          onSelected: (date) {
                            setState(() {
                              _plannedEndDate =
                                  date;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ProjectTaskStatus>(
                  initialValue: _status,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                  ),
                  items: ProjectTaskStatus.values
                      .map(
                        (status) =>
                            DropdownMenuItem<
                                ProjectTaskStatus>(
                          value: status,
                          child: Text(
                            _statusLabel(status),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      _status = value;

                      if (_status ==
                          ProjectTaskStatus.completed) {
                        _progressController.text =
                            '100';
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ProjectTaskPriority>(
                  initialValue: _priority,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                  ),
                  items: ProjectTaskPriority.values
                      .map(
                        (priority) =>
                            DropdownMenuItem<
                                ProjectTaskPriority>(
                          value: priority,
                          child: Text(
                            _priorityLabel(priority),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      _priority = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _progressController,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Progress (%)',
                    hintText: '0 - 100',
                  ),
                  validator: (value) {
                    final progress =
                        double.tryParse(
                      value?.trim() ?? '',
                    );

                    if (progress == null) {
                      return 'Enter a valid percentage.';
                    }

                    if (progress < 0 ||
                        progress > 100) {
                      return 'Progress must be between 0 and 100.';
                    }

                    if (_status ==
                            ProjectTaskStatus.completed &&
                        progress != 100) {
                      return 'Completed tasks must be at 100%.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(
            widget.task == null
                ? 'Add Task'
                : 'Save Changes',
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate({
    required DateTime initialDate,
    DateTime? firstDate,
    required ValueChanged<DateTime> onSelected,
  }) async {
    final today = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime(2020),
      lastDate: DateTime(today.year + 10),
    );

    if (selected != null) {
      onSelected(selected);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final progress = double.parse(
      _progressController.text.trim(),
    );

    final task = ProjectTask(
      id: widget.task?.id ?? '',
      projectId: widget.projectId,
      phaseId: _phaseId!,
      name: _nameController.text.trim(),
      description:
          _emptyToNull(_descriptionController.text),
      plannedStartDate: _plannedStartDate,
      plannedEndDate: _plannedEndDate,
      actualStartDate: widget.task?.actualStartDate,
      actualEndDate: widget.task?.actualEndDate,
      status: _status,
      priority: _priority,
      progress: progress,
      notes: _emptyToNull(_notesController.text),
      isArchived: widget.task?.isArchived ?? false,
    );

    Navigator.of(context).pop(task);
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();

    return trimmed.isEmpty ? null : trimmed;
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

  String _priorityLabel(
    ProjectTaskPriority priority,
  ) {
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

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(
            Icons.calendar_today_outlined,
          ),
        ),
        child: Text(
          '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}