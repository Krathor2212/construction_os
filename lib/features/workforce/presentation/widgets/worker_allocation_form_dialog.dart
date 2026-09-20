import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../domain/entities/worker_allocation.dart';

class WorkerAllocationFormDialog extends ConsumerStatefulWidget {
  const WorkerAllocationFormDialog({
    super.key,
    required this.workerId,
    this.allocation,
  });

  final String workerId;
  final WorkerAllocation? allocation;

  @override
  ConsumerState<WorkerAllocationFormDialog> createState() =>
      _WorkerAllocationFormDialogState();
}

class _WorkerAllocationFormDialogState
    extends ConsumerState<WorkerAllocationFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late DateTime _selectedDate;
  String? _projectId;

  late final TextEditingController _workDescriptionController;
  late final TextEditingController _plannedHoursController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();

    final allocation = widget.allocation;

    _selectedDate = allocation?.date ?? DateTime.now();
    _projectId = allocation?.projectId;

    _workDescriptionController = TextEditingController(
      text: allocation?.workDescription ?? '',
    );

    _plannedHoursController = TextEditingController(
      text: allocation?.plannedHours.toString() ?? '8',
    );

    _notesController = TextEditingController(
      text: allocation?.notes ?? '',
    );
  }

  @override
  void dispose() {
    _workDescriptionController.dispose();
    _plannedHoursController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      _selectedDate = selectedDate;
    });
  }

  void _onProjectChanged(String? value) {
    setState(() {
      _projectId = value;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_projectId == null) {
      return;
    }

    final plannedHours = double.tryParse(
      _plannedHoursController.text.trim(),
    );

    if (plannedHours == null) {
      return;
    }

    final allocation = WorkerAllocation(
      id: widget.allocation?.id ??
          'worker-allocation-'
              '${DateTime.now().millisecondsSinceEpoch}',
      workerId: widget.workerId,
      projectId: _projectId!,
      phaseId: widget.allocation?.phaseId,
      date: _selectedDate,
      workDescription:
          _workDescriptionController.text.trim(),
      plannedHours: plannedHours,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    Navigator.of(context).pop(allocation);
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsProvider);

    return AlertDialog(
      title: Text(
        widget.allocation == null
            ? 'Add Labour Allocation'
            : 'Edit Labour Allocation',
      ),
      scrollable: true,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(8),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(
                    Icons.calendar_today_outlined,
                  ),
                ),
                child: Text(
                  '${_selectedDate.day.toString().padLeft(2, '0')}/'
                  '${_selectedDate.month.toString().padLeft(2, '0')}/'
                  '${_selectedDate.year}',
                ),
              ),
            ),
            const SizedBox(
              height: AppSpacing.md,
            ),
            projectsAsync.when(
              loading: () => const InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Project',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text('Loading projects...'),
                  ],
                ),
              ),
              error: (error, stackTrace) => InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Project',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  'Unable to load projects.',
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .error,
                  ),
                ),
              ),
              data: (projects) {
                return DropdownButtonFormField<String>(
                  initialValue: projects.any(
                    (project) =>
                        project.id == _projectId,
                  )
                      ? _projectId
                      : null,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Project',
                    border: OutlineInputBorder(),
                  ),
                  items: projects.map((project) {
                    return DropdownMenuItem<String>(
                      value: project.id,
                      child: Text(
                        project.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: _onProjectChanged,
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a project';
                    }

                    return null;
                  },
                );
              },
            ),
            const SizedBox(
              height: AppSpacing.md,
            ),
            TextFormField(
              controller: _workDescriptionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Work Description',
                hintText: 'e.g. Foundation masonry work',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Enter the work description';
                }

                return null;
              },
            ),
            const SizedBox(
              height: AppSpacing.md,
            ),
            TextFormField(
              controller: _plannedHoursController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Planned Hours',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final hours = double.tryParse(
                  value?.trim() ?? '',
                );

                if (hours == null ||
                    hours <= 0 ||
                    hours > 24) {
                  return 'Enter hours between 0 and 24';
                }

                return null;
              },
            ),
            const SizedBox(
              height: AppSpacing.md,
            ),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
            ),
          ],
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
          child: const Text('Save'),
        ),
      ],
    );
  }
}
