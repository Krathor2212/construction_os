import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/project_phase.dart';
import '../providers/project_providers.dart';

class ProjectTimelinePage extends ConsumerWidget {
  const ProjectTimelinePage({
    required this.projectId,
    super.key,
  });

  final String projectId;

  Future<void> _showAddPhaseDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final created = await showDialog<bool>(
      context: context,
      builder: (_) => _AddPhaseDialog(projectId: projectId),
    );

    if (created == true) {
      ref.invalidate(projectPhasesProvider(projectId));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phasesAsync = ref.watch(
      projectPhasesProvider(projectId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Timeline'),
      ),
      body: phasesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                ),
                const SizedBox(height: AppSpacing.md),
                const Text('Unable to load project timeline.'),
                const SizedBox(height: AppSpacing.sm),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(
                      projectPhasesProvider(projectId),
                    );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (phases) {
          if (phases.isEmpty) {
            return const _EmptyTimelineView();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: phases.length,
            separatorBuilder: (_, _) => const SizedBox(
              height: AppSpacing.sm,
            ),
            itemBuilder: (context, index) {
              return _PhaseCard(
                phase: phases[index],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPhaseDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Phase'),
      ),
    );
  }
}

class _AddPhaseDialog extends ConsumerStatefulWidget {
  const _AddPhaseDialog({
    required this.projectId,
  });

  final String projectId;

  @override
  ConsumerState<_AddPhaseDialog> createState() => _AddPhaseDialogState();
}

class _AddPhaseDialogState extends ConsumerState<_AddPhaseDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _progressController = TextEditingController(text: '0');
  final _notesController = TextEditingController();

  late DateTime _plannedStartDate;
  DateTime? _plannedEndDate;

  ProjectPhaseStatus _status = ProjectPhaseStatus.notStarted;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _plannedStartDate = DateTime.now();
    _plannedEndDate = DateTime.now().add(
      const Duration(days: 7),
    );
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

      if (_plannedEndDate != null &&
          _plannedEndDate!.isBefore(_plannedStartDate)) {
        _plannedEndDate = _plannedStartDate;
      }
    });
  }

  Future<void> _selectPlannedEndDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _plannedEndDate ?? _plannedStartDate,
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

  Future<void> _savePhase() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_plannedEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select a planned end date.'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final progress =
          double.tryParse(_progressController.text.trim()) ?? 0;

      final phase = ProjectPhase(
        id: 'phase-${DateTime.now().millisecondsSinceEpoch}',
        projectId: widget.projectId,
        name: _nameController.text.trim(),
        plannedStartDate: _plannedStartDate,
        plannedEndDate: _plannedEndDate!,
        status: _status,
        progress: progress,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      final repository = ref.read(
        projectPhaseRepositoryProvider,
      );

      await repository.createPhase(phase);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phase created successfully.'),
        ),
      );
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
            'Unable to create phase: $error',
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
    return AlertDialog(
      title: const Text('Add Phase'),
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
                    labelText: 'Phase Name',
                    hintText: 'e.g. Foundation',
                    prefixIcon: Icon(
                      Icons.account_tree_outlined,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter a phase name';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.md),

                DropdownButtonFormField<ProjectPhaseStatus>(
                  initialValue: _status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    prefixIcon: Icon(
                      Icons.flag_outlined,
                    ),
                  ),
                  items: ProjectPhaseStatus.values.map((status) {
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
                  controller: _progressController,
                  keyboardType: const TextInputType.numberWithOptions(
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
                    if (value == null || value.trim().isEmpty) {
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

                const SizedBox(height: AppSpacing.md),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.calendar_today_outlined,
                  ),
                  title: const Text('Planned Start'),
                  subtitle: Text(
                    _formatDate(_plannedStartDate),
                  ),
                  trailing: TextButton(
                    onPressed: _selectPlannedStartDate,
                    child: const Text('Change'),
                  ),
                ),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.event_outlined,
                  ),
                  title: const Text('Planned End'),
                  subtitle: Text(
                    _plannedEndDate == null
                        ? 'Not set'
                        : _formatDate(_plannedEndDate!),
                  ),
                  trailing: TextButton(
                    onPressed: _selectPlannedEndDate,
                    child: const Text('Change'),
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                TextFormField(
                  controller: _notesController,
                  textCapitalization:
                      TextCapitalization.sentences,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Optional phase notes',
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
          onPressed: _isSaving ? null : _savePhase,
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
            _isSaving ? 'Saving...' : 'Save Phase',
          ),
        ),
      ],
    );
  }
}

class _PhaseCard extends StatelessWidget {
  const _PhaseCard({
    required this.phase,
  });

  final ProjectPhase phase;

  @override
  Widget build(BuildContext context) {
    final status = _statusInfo(phase.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  status.icon,
                  size: 26,
                  color: status.color,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    phase.name,
                    style:
                        Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Chip(
                  label: Text(status.label),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                Expanded(
                  child: _DateInfo(
                    label: 'Planned Start',
                    date: phase.plannedStartDate,
                  ),
                ),
                Expanded(
                  child: _DateInfo(
                    label: 'Planned End',
                    date: phase.plannedEndDate,
                  ),
                ),
              ],
            ),

            if (phase.actualStartDate != null ||
                phase.actualEndDate != null) ...[
              const SizedBox(height: AppSpacing.md),
              const Divider(),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _DateInfo(
                      label: 'Actual Start',
                      date: phase.actualStartDate,
                    ),
                  ),
                  Expanded(
                    child: _DateInfo(
                      label: 'Actual End',
                      date: phase.actualEndDate,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                Text(
                  'Progress',
                  style:
                      Theme.of(context).textTheme.labelMedium,
                ),
                const Spacer(),
                Text(
                  '${phase.progress.toStringAsFixed(0)}%',
                  style:
                      Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xs),

            LinearProgressIndicator(
              value: (phase.progress / 100).clamp(0, 1),
              minHeight: 7,
              borderRadius: BorderRadius.circular(10),
            ),

            if (phase.notes != null &&
                phase.notes!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                phase.notes!,
                style:
                    Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  _StatusInfo _statusInfo(ProjectPhaseStatus status) {
    return switch (status) {
      ProjectPhaseStatus.notStarted => const _StatusInfo(
          label: 'Not Started',
          icon: Icons.radio_button_unchecked,
          color: Colors.grey,
        ),
      ProjectPhaseStatus.inProgress => const _StatusInfo(
          label: 'In Progress',
          icon: Icons.play_circle_outline,
          color: Colors.blue,
        ),
      ProjectPhaseStatus.completed => const _StatusInfo(
          label: 'Completed',
          icon: Icons.check_circle_outline,
          color: Colors.green,
        ),
      ProjectPhaseStatus.delayed => const _StatusInfo(
          label: 'Delayed',
          icon: Icons.warning_amber_outlined,
          color: Colors.orange,
        ),
      ProjectPhaseStatus.onHold => const _StatusInfo(
          label: 'On Hold',
          icon: Icons.pause_circle_outline,
          color: Colors.red,
        ),
    };
  }
}

class _StatusInfo {
  const _StatusInfo({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

class _DateInfo extends StatelessWidget {
  const _DateInfo({
    required this.label,
    required this.date,
  });

  final String label;
  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          date == null ? '-' : _formatDate(date!),
          style:
              Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _EmptyTimelineView extends StatelessWidget {
  const _EmptyTimelineView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.timeline_outlined,
              size: 56,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No timeline phases yet',
              style:
                  Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Add project phases to start tracking '
              'the construction timeline.',
              textAlign: TextAlign.center,
              style:
                  Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}