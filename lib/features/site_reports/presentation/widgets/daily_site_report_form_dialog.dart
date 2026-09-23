import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../projects/domain/entities/project_phase.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../domain/entities/daily_site_report.dart';

class DailySiteReportFormDialog extends ConsumerStatefulWidget {
  const DailySiteReportFormDialog({
    super.key,
    this.initialReport,
  });

  final DailySiteReport? initialReport;

  @override
  ConsumerState<DailySiteReportFormDialog> createState() =>
      _DailySiteReportFormDialogState();
}

class _DailySiteReportFormDialogState
    extends ConsumerState<DailySiteReportFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late DateTime _selectedDate;
  String? _selectedProjectId;
  String? _selectedPhaseId;

  late final TextEditingController _workCompletedController;
  late final TextEditingController _workPlannedController;
  late final TextEditingController _issuesController;
  late final TextEditingController _safetyController;
  late final TextEditingController _qualityController;
  late final TextEditingController _generalController;

  bool get _isEditing => widget.initialReport != null;

  @override
  void initState() {
    super.initState();

    final report = widget.initialReport;

    _selectedDate = report?.date ?? DateTime.now();
    _selectedProjectId = report?.projectId;
    _selectedPhaseId = report?.phaseId;

    _workCompletedController = TextEditingController(
      text: report?.workCompleted ?? '',
    );

    _workPlannedController = TextEditingController(
      text: report?.workPlannedForNextDay ?? '',
    );

    _issuesController = TextEditingController(
      text: report?.issuesAndDelays ?? '',
    );

    _safetyController = TextEditingController(
      text: report?.safetyNotes ?? '',
    );

    _qualityController = TextEditingController(
      text: report?.qualityNotes ?? '',
    );

    _generalController = TextEditingController(
      text: report?.generalNotes ?? '',
    );
  }

  @override
  void dispose() {
    _workCompletedController.dispose();
    _workPlannedController.dispose();
    _issuesController.dispose();
    _safetyController.dispose();
    _qualityController.dispose();
    _generalController.dispose();
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

  void _onProjectChanged(String? projectId) {
    setState(() {
      _selectedProjectId = projectId;
      _selectedPhaseId = null;
    });
  }

  void _onPhaseChanged(String? phaseId) {
    setState(() {
      _selectedPhaseId = phaseId;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final projectId = _selectedProjectId;

    if (projectId == null) {
      return;
    }

    final report = DailySiteReport(
      id: widget.initialReport?.id ??
          'site-report-${DateTime.now().microsecondsSinceEpoch}',
      projectId: projectId,
      phaseId: _selectedPhaseId,
      date: _selectedDate,
      workCompleted: _workCompletedController.text.trim(),
      workPlannedForNextDay: _workPlannedController.text.trim(),
      issuesAndDelays: _issuesController.text.trim(),
      safetyNotes: _safetyController.text.trim(),
      qualityNotes: _qualityController.text.trim(),
      generalNotes: _generalController.text.trim().isEmpty
          ? null
          : _generalController.text.trim(),
    );

    Navigator.of(context).pop(report);
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsProvider);

    return AlertDialog(
      title: Text(
        _isEditing ? 'Edit Daily Site Report' : 'Add Daily Site Report',
      ),
      content: SizedBox(
        width: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                projectsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, stackTrace) => Text(
                    'Unable to load projects: $error',
                  ),
                  data: (projects) {
                    if (_selectedProjectId != null &&
                        !projects.any(
                          (project) => project.id == _selectedProjectId,
                        )) {
                      _selectedProjectId = null;
                      _selectedPhaseId = null;
                    }

                    return DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _selectedProjectId,
                      decoration: const InputDecoration(
                        labelText: 'Project',
                        border: OutlineInputBorder(),
                      ),
                      items: projects.map((project) {
                        return DropdownMenuItem<String>(
                          value: project.id,
                          child: Text(
                            project.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: _onProjectChanged,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a project.';
                        }

                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                if (_selectedProjectId != null)
                  ref
                      .watch(
                        projectPhasesProvider(
                          _selectedProjectId!,
                        ),
                      )
                      .when(
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: LinearProgressIndicator(),
                        ),
                        error: (error, stackTrace) => Text(
                          'Unable to load phases: $error',
                        ),
                        data: (phases) {
                          final activePhases = phases
                              .where(
                                (phase) => !phase.isArchived,
                              )
                              .toList();

                          if (_selectedPhaseId != null &&
                              !activePhases.any(
                                (phase) =>
                                    phase.id == _selectedPhaseId,
                              )) {
                            _selectedPhaseId = null;
                          }

                          return DropdownButtonFormField<String?>(
                            isExpanded: true,
                            initialValue: _selectedPhaseId,
                            decoration: const InputDecoration(
                              labelText: 'Phase',
                              hintText: 'Optional',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text(
                                  'Whole Project',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              ...activePhases.map(
                                (ProjectPhase phase) {
                                  return DropdownMenuItem<String?>(
                                    value: phase.id,
                                    child: Text(
                                      phase.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                },
                              ),
                            ],
                            onChanged: _onPhaseChanged,
                          );
                        },
                      ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(4),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Report Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      MaterialLocalizations.of(context)
                          .formatMediumDate(_selectedDate),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _workCompletedController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Work Completed',
                    hintText: 'Describe the work completed today.',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter completed work.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _workPlannedController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Work Planned for Next Day',
                    hintText: 'Describe the planned work for tomorrow.',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter planned work.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _issuesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Issues & Delays',
                    hintText: 'Record problems, delays, or blockers.',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _safetyController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Safety Notes',
                    hintText: 'Record safety observations or incidents.',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _qualityController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Quality Notes',
                    hintText: 'Record inspections or quality observations.',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _generalController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'General Notes',
                    hintText: 'Additional site information.',
                    border: OutlineInputBorder(),
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
            _isEditing ? 'Save Changes' : 'Create Report',
          ),
        ),
      ],
    );
  }
}