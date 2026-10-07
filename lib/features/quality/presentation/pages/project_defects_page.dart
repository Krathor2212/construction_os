import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../projects/domain/entities/project_phase.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../../tasks/presentation/providers/project_task_providers.dart';
import '../../domain/entities/defect.dart';
import '../providers/defect_providers.dart';

class ProjectDefectsPage extends ConsumerWidget {
  const ProjectDefectsPage({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defectsAsync = ref.watch(projectDefectsProvider(projectId));
    return Scaffold(
      appBar: AppBar(title: const Text('Defects')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addDefect(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Report defect'),
      ),
      body: defectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Unable to load defects: $error')),
        data: (defects) => defects.isEmpty
            ? const Center(child: Text('No defects reported yet.'))
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: defects.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, index) =>
                    _DefectCard(defect: defects[index]),
              ),
      ),
    );
  }

  Future<void> _addDefect(BuildContext context, WidgetRef ref) async {
    final defect = await showDialog<Defect>(
      context: context,
      builder: (_) => _DefectForm(projectId: projectId),
    );
    if (defect == null || !context.mounted) return;
    await ref.read(defectActionsProvider).createDefect(defect);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Defect reported successfully.')),
    );
  }
}

class _DefectCard extends ConsumerWidget {
  const _DefectCard({required this.defect});

  final Defect defect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(projectTasksProvider(defect.projectId));
    final taskName = tasksAsync.when(
      loading: () => null,
      error: (_, _) => null,
      data: (tasks) => tasks
          .where((task) => task.id == defect.taskId)
          .map((task) => task.name)
          .firstOrNull,
    );
    final color = _severityColor(context, defect.severity);
    return Card(
      child: ListTile(
        leading: Icon(Icons.report_problem_outlined, color: color),
        title: Text(defect.title),
        subtitle: Text(
          '${_severityLabel(defect.severity)} • '
          '${_statusLabel(defect.status)}\n'
          '${defect.location}${taskName == null ? '' : ' • $taskName'}\n'
          '${defect.description}',
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<DefectStatus>(
          tooltip: 'Update status',
          onSelected: (status) => _updateStatus(context, ref, status),
          itemBuilder: (_) => DefectStatus.values
              .map(
                (status) => PopupMenuItem(
                  value: status,
                  child: Text(_statusLabel(status)),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Future<void> _updateStatus(
    BuildContext context,
    WidgetRef ref,
    DefectStatus status,
  ) async {
    await ref.read(defectActionsProvider).updateDefect(
          Defect(
            id: defect.id,
            projectId: defect.projectId,
            phaseId: defect.phaseId,
            taskId: defect.taskId,
            title: defect.title,
            description: defect.description,
            location: defect.location,
            reportedDate: defect.reportedDate,
            severity: defect.severity,
            status: status,
          ),
        );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Defect marked ${_statusLabel(status).toLowerCase()}.')),
    );
  }
}

class _DefectForm extends ConsumerStatefulWidget {
  const _DefectForm({required this.projectId});

  final String projectId;

  @override
  ConsumerState<_DefectForm> createState() => _DefectFormState();
}

class _DefectFormState extends ConsumerState<_DefectForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  DefectSeverity _severity = DefectSeverity.medium;
  String? _phaseId;
  String? _taskId;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phasesAsync = ref.watch(projectPhasesProvider(widget.projectId));
    final tasksAsync = ref.watch(projectTasksProvider(widget.projectId));
    return AlertDialog(
      title: const Text('Report defect'),
      content: SizedBox(
        width: 540,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _requiredField(_titleController, 'Title'),
                const SizedBox(height: AppSpacing.sm),
                _requiredField(_locationController, 'Location'),
                const SizedBox(height: AppSpacing.sm),
                _PhaseDropdown(
                  phasesAsync: phasesAsync,
                  value: _phaseId,
                  onChanged: (value) => setState(() => _phaseId = value),
                ),
                const SizedBox(height: AppSpacing.sm),
                tasksAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, _) => const Text('Unable to load tasks.'),
                  data: (tasks) => DropdownButtonFormField<String>(
                    initialValue: _taskId,
                    decoration: const InputDecoration(
                      labelText: 'Task (optional)',
                    ),
                    items: tasks
                        .map(
                          (task) => DropdownMenuItem(
                            value: task.id,
                            child: Text(task.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _taskId = value),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<DefectSeverity>(
                  initialValue: _severity,
                  decoration: const InputDecoration(labelText: 'Severity'),
                  items: DefectSeverity.values
                      .map(
                        (severity) => DropdownMenuItem(
                          value: severity,
                          child: Text(_severityLabel(severity)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _severity = value);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a description.'
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }

  TextFormField _requiredField(
    TextEditingController controller,
    String label,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: (value) => value == null || value.trim().isEmpty
          ? 'Enter $label.'
          : null,
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate() || _phaseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a phase before saving.')),
      );
      return;
    }
    Navigator.pop(
      context,
      Defect(
        id: 'defect-${DateTime.now().microsecondsSinceEpoch}',
        projectId: widget.projectId,
        phaseId: _phaseId!,
        taskId: _taskId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        reportedDate: DateTime.now(),
        severity: _severity,
        status: DefectStatus.open,
      ),
    );
  }
}

class _PhaseDropdown extends StatelessWidget {
  const _PhaseDropdown({
    required this.phasesAsync,
    required this.value,
    required this.onChanged,
  });

  final AsyncValue<List<ProjectPhase>> phasesAsync;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return phasesAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, _) => const Text('Unable to load phases.'),
      data: (phases) => DropdownButtonFormField<String>(
        initialValue: value,
        decoration: const InputDecoration(labelText: 'Phase'),
        items: phases
            .map(
              (phase) => DropdownMenuItem(
                value: phase.id,
                child: Text(phase.name),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

Color _severityColor(BuildContext context, DefectSeverity severity) {
  switch (severity) {
    case DefectSeverity.low:
      return Colors.blue;
    case DefectSeverity.medium:
      return Colors.orange;
    case DefectSeverity.high:
      return Colors.deepOrange;
    case DefectSeverity.critical:
      return Theme.of(context).colorScheme.error;
  }
}

String _severityLabel(DefectSeverity severity) {
  switch (severity) {
    case DefectSeverity.low:
      return 'Low';
    case DefectSeverity.medium:
      return 'Medium';
    case DefectSeverity.high:
      return 'High';
    case DefectSeverity.critical:
      return 'Critical';
  }
}

String _statusLabel(DefectStatus status) {
  switch (status) {
    case DefectStatus.open:
      return 'Open';
    case DefectStatus.inProgress:
      return 'In progress';
    case DefectStatus.resolved:
      return 'Resolved';
  }
}
