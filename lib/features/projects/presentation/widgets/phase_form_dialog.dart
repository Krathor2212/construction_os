import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/project_phase.dart';
import '../providers/project_providers.dart';

class PhaseFormDialog extends ConsumerStatefulWidget {
  const PhaseFormDialog({
    required this.projectId,
    this.phase,
    super.key,
  });

  final String projectId;
  final ProjectPhase? phase;

  bool get isEditing => phase != null;

  @override
  ConsumerState<PhaseFormDialog> createState() =>
      _PhaseFormDialogState();
}

class _PhaseFormDialogState
    extends ConsumerState<PhaseFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _progressController;
  late final TextEditingController _notesController;

  late DateTime _plannedStartDate;
  late DateTime _plannedEndDate;

  late ProjectPhaseStatus _status;

  DateTime? _actualStartDate;
  DateTime? _actualEndDate;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final phase = widget.phase;

    _nameController = TextEditingController(
      text: phase?.name ?? '',
    );

    _progressController = TextEditingController(
      text: phase?.progress.toStringAsFixed(0) ?? '0',
    );

    _notesController = TextEditingController(
      text: phase?.notes ?? '',
    );

    _plannedStartDate =
        phase?.plannedStartDate ?? DateTime.now();

    _plannedEndDate =
        phase?.plannedEndDate ??
        DateTime.now().add(
          const Duration(days: 7),
        );

    _status =
        phase?.status ?? ProjectPhaseStatus.notStarted;

    _actualStartDate = phase?.actualStartDate;
    _actualEndDate = phase?.actualEndDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _progressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectPlannedStartDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _plannedStartDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _plannedStartDate = selected;

      if (_plannedEndDate.isBefore(_plannedStartDate)) {
        _plannedEndDate = _plannedStartDate;
      }
    });
  }

  Future<void> _selectPlannedEndDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _plannedEndDate,
      firstDate: _plannedStartDate,
      lastDate: DateTime(2100),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _plannedEndDate = selected;
    });
  }

  Future<void> _selectActualStartDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate:
          _actualStartDate ?? _plannedStartDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _actualStartDate = selected;

      if (_actualEndDate != null &&
          _actualEndDate!.isBefore(selected)) {
        _actualEndDate = null;
      }
    });
  }

  Future<void> _selectActualEndDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate:
          _actualEndDate ??
          _actualStartDate ??
          _plannedEndDate,
      firstDate:
          _actualStartDate ?? DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _actualEndDate = selected;
    });
  }

  Future<void> _savePhase() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final progress =
          double.tryParse(
                _progressController.text.trim(),
              ) ??
              0;

      final existingPhase = widget.phase;

      final phase = ProjectPhase(
        id: existingPhase?.id ??
            'phase-${DateTime.now().millisecondsSinceEpoch}',
        projectId: widget.projectId,
        name: _nameController.text.trim(),
        plannedStartDate: _plannedStartDate,
        plannedEndDate: _plannedEndDate,
        actualStartDate: _actualStartDate,
        actualEndDate: _actualEndDate,
        status: _status,
        progress: progress,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        isArchived: existingPhase?.isArchived ?? false,
      );

      final repository = ref.read(
        projectPhaseRepositoryProvider,
      );

      if (widget.isEditing) {
        await repository.updatePhase(phase);
      } else {
        await repository.createPhase(phase);
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Unable to update phase: $error'
                : 'Unable to create phase: $error',
          ),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _statusLabel(ProjectPhaseStatus status) {
    return switch (status) {
      ProjectPhaseStatus.notStarted => 'Not Started',
      ProjectPhaseStatus.inProgress => 'In Progress',
      ProjectPhaseStatus.completed => 'Completed',
      ProjectPhaseStatus.delayed => 'Delayed',
      ProjectPhaseStatus.onHold => 'On Hold',
    };
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEditing
        ? 'Edit Phase'
        : 'Add Phase';

    final saveLabel = widget.isEditing
        ? 'Update Phase'
        : 'Save Phase';

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
                  textCapitalization:
                      TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Phase Name',
                    hintText: 'e.g. Foundation',
                    prefixIcon: Icon(
                      Icons.account_tree_outlined,
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Enter a phase name';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: AppSpacing.md,
                ),

                DropdownButtonFormField<
                    ProjectPhaseStatus>(
                  initialValue: _status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    prefixIcon: Icon(
                      Icons.flag_outlined,
                    ),
                  ),
                  items:
                      ProjectPhaseStatus.values.map(
                    (status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(
                          _statusLabel(status),
                        ),
                      );
                    },
                  ).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _status = value;
                      });
                    }
                  },
                ),

                const SizedBox(
                  height: AppSpacing.md,
                ),

                TextFormField(
                  controller: _progressController,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Progress',
                    hintText: '0 - 100',
                    suffixText: '%',
                    prefixIcon: Icon(
                      Icons.percent_outlined,
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Enter progress';
                    }

                    final progress =
                        double.tryParse(value.trim());

                    if (progress == null ||
                        progress < 0 ||
                        progress > 100) {
                      return 'Enter a value between 0 and 100';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: AppSpacing.md,
                ),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.calendar_today_outlined,
                  ),
                  title: const Text(
                    'Planned Start',
                  ),
                  subtitle: Text(
                    _formatDate(
                      _plannedStartDate,
                    ),
                  ),
                  trailing: TextButton(
                    onPressed:
                        _selectPlannedStartDate,
                    child: const Text('Change'),
                  ),
                ),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.event_outlined,
                  ),
                  title: const Text(
                    'Planned End',
                  ),
                  subtitle: Text(
                    _formatDate(
                      _plannedEndDate,
                    ),
                  ),
                  trailing: TextButton(
                    onPressed:
                        _selectPlannedEndDate,
                    child: const Text('Change'),
                  ),
                ),

                const Divider(),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.play_circle_outline,
                  ),
                  title: const Text(
                    'Actual Start',
                  ),
                  subtitle: Text(
                    _actualStartDate == null
                        ? 'Not set'
                        : _formatDate(
                            _actualStartDate!,
                          ),
                  ),
                  trailing: TextButton(
                    onPressed:
                        _selectActualStartDate,
                    child: const Text('Change'),
                  ),
                ),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.check_circle_outline,
                  ),
                  title: const Text(
                    'Actual End',
                  ),
                  subtitle: Text(
                    _actualEndDate == null
                        ? 'Not set'
                        : _formatDate(
                            _actualEndDate!,
                          ),
                  ),
                  trailing: TextButton(
                    onPressed:
                        _selectActualEndDate,
                    child: const Text('Change'),
                  ),
                ),

                const SizedBox(
                  height: AppSpacing.sm,
                ),

                TextFormField(
                  controller: _notesController,
                  textCapitalization:
                      TextCapitalization.sentences,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText:
                        'Optional phase notes',
                    prefixIcon: Icon(
                      Icons.notes_outlined,
                    ),
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
          onPressed:
              _isSaving ? null : _savePhase,
          icon: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Icon(
                  Icons.save_outlined,
                ),
          label: Text(
            _isSaving
                ? 'Saving...'
                : saveLabel,
          ),
        ),
      ],
    );
  }
}