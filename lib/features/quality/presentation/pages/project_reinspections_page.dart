import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../projects/domain/entities/project_phase.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../../tasks/presentation/providers/project_task_providers.dart';
import '../../domain/entities/reinspection.dart';
import '../providers/corrective_action_providers.dart';
import '../providers/reinspection_providers.dart';

class ProjectReinspectionsPage extends ConsumerWidget {
  const ProjectReinspectionsPage({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reinspectionsAsync =
        ref.watch(projectReinspectionsProvider(projectId));
    return Scaffold(
      appBar: AppBar(title: const Text('Reinspection')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addReinspection(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add reinspection'),
      ),
      body: reinspectionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Unable to load reinspections: $error')),
        data: (reinspections) => reinspections.isEmpty
            ? const Center(child: Text('No reinspections recorded yet.'))
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: reinspections.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, index) =>
                    _ReinspectionCard(reinspection: reinspections[index]),
              ),
      ),
    );
  }

  Future<void> _addReinspection(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final reinspection = await showDialog<Reinspection>(
      context: context,
      builder: (_) => _ReinspectionForm(projectId: projectId),
    );
    if (reinspection == null || !context.mounted) return;
    await ref
        .read(reinspectionActionsProvider)
        .createReinspection(reinspection);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reinspection recorded successfully.')),
    );
  }
}

class _ReinspectionCard extends ConsumerWidget {
  const _ReinspectionCard({required this.reinspection});

  final Reinspection reinspection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionsAsync =
        ref.watch(projectCorrectiveActionsProvider(reinspection.projectId));
    final actionTitle = actionsAsync.when(
      loading: () => reinspection.correctiveActionId,
      error: (_, _) => reinspection.correctiveActionId,
      data: (actions) => actions
          .where((action) => action.id == reinspection.correctiveActionId)
          .map((action) => action.title)
          .firstOrNull ?? reinspection.correctiveActionId,
    );
    final color = _resultColor(context, reinspection.result);
    return Card(
      child: ListTile(
        leading: Icon(Icons.fact_check_outlined, color: color),
        title: Text(_resultLabel(reinspection.result)),
        subtitle: Text(
          '${_formatDate(reinspection.date)} • ${reinspection.inspectorName}\n'
          'Action: $actionTitle\n'
          'Original result: ${reinspection.originalInspectionResult}\n'
          '${reinspection.notes}',
        ),
        isThreeLine: true,
      ),
    );
  }
}

class _ReinspectionForm extends ConsumerStatefulWidget {
  const _ReinspectionForm({required this.projectId});

  final String projectId;

  @override
  ConsumerState<_ReinspectionForm> createState() => _ReinspectionFormState();
}

class _ReinspectionFormState extends ConsumerState<_ReinspectionForm> {
  final _formKey = GlobalKey<FormState>();
  final _inspectorController = TextEditingController();
  final _notesController = TextEditingController();
  final _originalResultController = TextEditingController();
  ReinspectionResult _result = ReinspectionResult.passed;
  DateTime _date = DateTime.now();
  String? _phaseId;
  String? _taskId;
  String? _correctiveActionId;

  @override
  void dispose() {
    _inspectorController.dispose();
    _notesController.dispose();
    _originalResultController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phasesAsync = ref.watch(projectPhasesProvider(widget.projectId));
    final tasksAsync = ref.watch(projectTasksProvider(widget.projectId));
    final actionsAsync =
        ref.watch(projectCorrectiveActionsProvider(widget.projectId));
    return AlertDialog(
      title: const Text('Add reinspection'),
      content: SizedBox(
        width: 540,
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
                actionsAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, _) => const Text(
                    'Unable to load corrective actions.',
                  ),
                  data: (actions) => DropdownButtonFormField<String>(
                    initialValue: _correctiveActionId,
                    decoration: const InputDecoration(
                      labelText: 'Corrective action',
                    ),
                    items: actions
                        .map(
                          (action) => DropdownMenuItem(
                            value: action.id,
                            child: Text(action.title),
                          ),
                        )
                        .toList(),
                    validator: (value) => value == null
                        ? 'Select a corrective action.'
                        : null,
                    onChanged: (value) =>
                        setState(() => _correctiveActionId = value),
                  ),
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
                TextFormField(
                  controller: _originalResultController,
                  decoration: const InputDecoration(
                    labelText: 'Original inspection result',
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter the original inspection result.'
                      : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<ReinspectionResult>(
                  initialValue: _result,
                  decoration: const InputDecoration(labelText: 'Result'),
                  items: ReinspectionResult.values
                      .map(
                        (result) => DropdownMenuItem(
                          value: result,
                          child: Text(_resultLabel(result)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _result = value);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Inspection date'),
                  subtitle: Text(_formatDate(_date)),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: _pickDate,
                ),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Notes'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter reinspection notes.'
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: _date,
    );
    if (picked != null) setState(() => _date = picked);
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
      Reinspection(
        id: 'reinspection-${DateTime.now().microsecondsSinceEpoch}',
        projectId: widget.projectId,
        phaseId: _phaseId!,
        taskId: _taskId,
        correctiveActionId: _correctiveActionId!,
        originalInspectionResult: _originalResultController.text.trim(),
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

Color _resultColor(BuildContext context, ReinspectionResult result) {
  return switch (result) {
    ReinspectionResult.passed => Colors.green,
    ReinspectionResult.failed => Theme.of(context).colorScheme.error,
    ReinspectionResult.requiresAttention => Colors.orange,
  };
}

String _resultLabel(ReinspectionResult result) => switch (result) {
      ReinspectionResult.passed => 'Passed',
      ReinspectionResult.failed => 'Failed',
      ReinspectionResult.requiresAttention => 'Requires attention',
    };

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/${date.year}';
