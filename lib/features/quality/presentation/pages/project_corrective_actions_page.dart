import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../projects/domain/entities/project_phase.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../../tasks/presentation/providers/project_task_providers.dart';
import '../../domain/entities/corrective_action.dart';
import '../providers/corrective_action_providers.dart';

class ProjectCorrectiveActionsPage extends ConsumerWidget {
  const ProjectCorrectiveActionsPage({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionsAsync = ref.watch(projectCorrectiveActionsProvider(projectId));
    return Scaffold(
      appBar: AppBar(title: const Text('Corrective Actions')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addAction(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add action'),
      ),
      body: actionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Unable to load corrective actions: $error')),
        data: (actions) => actions.isEmpty
            ? const Center(child: Text('No corrective actions recorded yet.'))
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: actions.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, index) =>
                    _ActionCard(action: actions[index]),
              ),
      ),
    );
  }

  Future<void> _addAction(BuildContext context, WidgetRef ref) async {
    final action = await showDialog<CorrectiveAction>(
      context: context,
      builder: (_) => _ActionForm(projectId: projectId),
    );
    if (action == null || !context.mounted) return;
    await ref.read(correctiveActionActionsProvider).createAction(action);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Corrective action added successfully.')),
    );
  }
}

class _ActionCard extends ConsumerWidget {
  const _ActionCard({required this.action});

  final CorrectiveAction action;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(projectTasksProvider(action.projectId));
    final taskName = tasksAsync.when(
      loading: () => null,
      error: (_, _) => null,
      data: (tasks) => tasks
          .where((task) => task.id == action.taskId)
          .map((task) => task.name)
          .firstOrNull,
    );
    final overdue = action.status != CorrectiveActionStatus.completed &&
        DateUtils.dateOnly(action.dueDate).isBefore(DateUtils.dateOnly(DateTime.now()));
    final priorityColor = _priorityColor(context, action.priority);
    return Card(
      child: ListTile(
        leading: Icon(Icons.build_circle_outlined, color: priorityColor),
        title: Text(action.title),
        subtitle: Text(
          '${_priorityLabel(action.priority)} • ${_statusLabel(action.status)}\n'
          'Due ${_formatDate(action.dueDate)}'
          '${overdue ? ' • Overdue' : ''} • ${action.responsiblePerson}\n'
          '${taskName == null ? '' : '$taskName • '}${action.description}',
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<CorrectiveActionStatus>(
          tooltip: 'Update status',
          onSelected: (status) => _updateStatus(context, ref, status),
          itemBuilder: (_) => CorrectiveActionStatus.values
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
    CorrectiveActionStatus status,
  ) async {
    await ref.read(correctiveActionActionsProvider).updateAction(
          CorrectiveAction(
            id: action.id,
            projectId: action.projectId,
            phaseId: action.phaseId,
            taskId: action.taskId,
            title: action.title,
            description: action.description,
            responsiblePerson: action.responsiblePerson,
            dueDate: action.dueDate,
            priority: action.priority,
            status: status,
            createdDate: action.createdDate,
          ),
        );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Action marked ${_statusLabel(status).toLowerCase()}.',
        ),
      ),
    );
  }
}

class _ActionForm extends ConsumerStatefulWidget {
  const _ActionForm({required this.projectId});

  final String projectId;

  @override
  ConsumerState<_ActionForm> createState() => _ActionFormState();
}

class _ActionFormState extends ConsumerState<_ActionForm> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _responsiblePerson = TextEditingController();
  CorrectiveActionPriority _priority = CorrectiveActionPriority.medium;
  String? _phaseId;
  String? _taskId;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _responsiblePerson.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phasesAsync = ref.watch(projectPhasesProvider(widget.projectId));
    final tasksAsync = ref.watch(projectTasksProvider(widget.projectId));
    return AlertDialog(
      title: const Text('Add corrective action'),
      content: SizedBox(
        width: 540,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(_title, 'Title'),
                const SizedBox(height: AppSpacing.sm),
                _field(_responsiblePerson, 'Responsible person'),
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
                DropdownButtonFormField<CorrectiveActionPriority>(
                  initialValue: _priority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: CorrectiveActionPriority.values
                      .map(
                        (priority) => DropdownMenuItem(
                          value: priority,
                          child: Text(_priorityLabel(priority)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _priority = value);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Due date'),
                  subtitle: Text(_formatDate(_dueDate)),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: _pickDueDate,
                ),
                _field(_description, 'Description', maxLines: 3),
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

  TextFormField _field(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
      validator: (value) => value == null || value.trim().isEmpty
          ? 'Enter $label.'
          : null,
    );
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: _dueDate,
    );
    if (picked != null) setState(() => _dueDate = picked);
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
      CorrectiveAction(
        id: 'action-${DateTime.now().microsecondsSinceEpoch}',
        projectId: widget.projectId,
        phaseId: _phaseId!,
        taskId: _taskId,
        title: _title.text.trim(),
        description: _description.text.trim(),
        responsiblePerson: _responsiblePerson.text.trim(),
        dueDate: _dueDate,
        priority: _priority,
        status: CorrectiveActionStatus.open,
        createdDate: DateTime.now(),
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

Color _priorityColor(
  BuildContext context,
  CorrectiveActionPriority priority,
) {
  return switch (priority) {
    CorrectiveActionPriority.low => Colors.blue,
    CorrectiveActionPriority.medium => Colors.orange,
    CorrectiveActionPriority.high => Colors.deepOrange,
    CorrectiveActionPriority.critical => Theme.of(context).colorScheme.error,
  };
}

String _priorityLabel(CorrectiveActionPriority priority) => switch (priority) {
      CorrectiveActionPriority.low => 'Low',
      CorrectiveActionPriority.medium => 'Medium',
      CorrectiveActionPriority.high => 'High',
      CorrectiveActionPriority.critical => 'Critical',
    };

String _statusLabel(CorrectiveActionStatus status) => switch (status) {
      CorrectiveActionStatus.open => 'Open',
      CorrectiveActionStatus.inProgress => 'In progress',
      CorrectiveActionStatus.completed => 'Completed',
    };

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/${date.year}';
