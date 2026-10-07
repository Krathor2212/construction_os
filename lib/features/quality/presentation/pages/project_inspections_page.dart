import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../projects/domain/entities/project_phase.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../../tasks/presentation/providers/project_task_providers.dart';
import '../../domain/entities/inspection.dart';
import '../providers/inspection_providers.dart';

class ProjectInspectionsPage extends ConsumerWidget {
  const ProjectInspectionsPage({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inspectionsAsync = ref.watch(projectInspectionsProvider(projectId));
    return Scaffold(
      appBar: AppBar(title: const Text('Inspections')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createInspection(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add inspection'),
      ),
      body: inspectionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Unable to load inspections: $error')),
        data: (inspections) => inspections.isEmpty
            ? const Center(child: Text('No inspections recorded yet.'))
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: inspections.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, index) =>
                    _InspectionCard(inspection: inspections[index]),
              ),
      ),
    );
  }

  Future<void> _createInspection(BuildContext context, WidgetRef ref) async {
    final inspection = await showDialog<Inspection>(
      context: context,
      builder: (_) => _InspectionForm(projectId: projectId),
    );
    if (inspection == null || !context.mounted) return;
    await ref.read(inspectionActionsProvider).createInspection(inspection);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Inspection recorded successfully.')),
    );
  }
}

class _InspectionCard extends ConsumerWidget {
  const _InspectionCard({required this.inspection});

  final Inspection inspection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(projectTasksProvider(inspection.projectId));
    final taskName = tasksAsync.when(
      loading: () => null,
      error: (_, _) => null,
      data: (tasks) => tasks
          .where((task) => task.id == inspection.taskId)
          .map((task) => task.name)
          .firstOrNull,
    );
    final color = switch (inspection.result) {
      InspectionResult.passed => Colors.green,
      InspectionResult.failed => Theme.of(context).colorScheme.error,
      InspectionResult.requiresAttention => Colors.orange,
    };
    return Card(
      child: ListTile(
        leading: Icon(Icons.fact_check_outlined, color: color),
        title: Text(_resultLabel(inspection.result)),
        subtitle: Text(
          '${_formatDate(inspection.date)} • ${inspection.inspectorName}'
          '${taskName == null ? '' : '\nTask: $taskName'}\n${inspection.notes}',
        ),
        isThreeLine: true,
      ),
    );
  }
}

class _InspectionForm extends ConsumerStatefulWidget {
  const _InspectionForm({required this.projectId});

  final String projectId;

  @override
  ConsumerState<_InspectionForm> createState() => _InspectionFormState();
}

class _InspectionFormState extends ConsumerState<_InspectionForm> {
  final _formKey = GlobalKey<FormState>();
  final _inspectorController = TextEditingController();
  final _notesController = TextEditingController();
  InspectionResult _result = InspectionResult.passed;
  final DateTime _date = DateTime.now();
  String? _phaseId;
  String? _taskId;

  @override
  void dispose() {
    _inspectorController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phasesAsync = ref.watch(projectPhasesProvider(widget.projectId));
    final tasksAsync = ref.watch(projectTasksProvider(widget.projectId));
    return AlertDialog(
      title: const Text('Add inspection'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _inspectorController,
                  decoration: const InputDecoration(labelText: 'Inspector'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter the inspector name.'
                      : null,
                ),
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
                DropdownButtonFormField<InspectionResult>(
                  initialValue: _result,
                  decoration: const InputDecoration(labelText: 'Result'),
                  items: InspectionResult.values
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(_resultLabel(value)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _result = value);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Notes'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter inspection notes.'
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

  void _save() {
    if (!_formKey.currentState!.validate() || _phaseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a phase before saving.')),
      );
      return;
    }
    Navigator.pop(
      context,
      Inspection(
        id: 'inspection-${DateTime.now().microsecondsSinceEpoch}',
        projectId: widget.projectId,
        phaseId: _phaseId!,
        taskId: _taskId,
        date: _date,
        inspectorName: _inspectorController.text.trim(),
        result: _result,
        notes: _notesController.text.trim(),
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
              (phase) => DropdownMenuItem<String>(
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

String _resultLabel(InspectionResult result) {
  switch (result) {
    case InspectionResult.passed:
      return 'Passed';
    case InspectionResult.failed:
      return 'Failed';
    case InspectionResult.requiresAttention:
      return 'Requires attention';
  }
}

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
