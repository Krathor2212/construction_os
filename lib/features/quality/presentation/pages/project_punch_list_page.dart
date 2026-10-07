import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../projects/domain/entities/project_phase.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../../tasks/presentation/providers/project_task_providers.dart';
import '../../domain/entities/punch_list_item.dart';
import '../providers/punch_list_providers.dart';

class ProjectPunchListPage extends ConsumerWidget {
  const ProjectPunchListPage({super.key, required this.projectId});
  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(projectPunchListProvider(projectId));
    return Scaffold(
      appBar: AppBar(title: const Text('Snag / Punch List')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addItem(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add snag'),
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Unable to load punch list: $error')),
        data: (items) => items.isEmpty
            ? const Center(child: Text('No snag items recorded yet.'))
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, index) => _PunchCard(item: items[index]),
              ),
      ),
    );
  }

  Future<void> _addItem(BuildContext context, WidgetRef ref) async {
    final item = await showDialog<PunchListItem>(
      context: context,
      builder: (_) => _PunchForm(projectId: projectId),
    );
    if (item == null || !context.mounted) return;
    await ref.read(punchListActionsProvider).createItem(item);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Snag added successfully.')),
    );
  }
}

class _PunchCard extends ConsumerWidget {
  const _PunchCard({required this.item});
  final PunchListItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(projectTasksProvider(item.projectId));
    final taskName = tasksAsync.when(
      loading: () => null,
      error: (_, _) => null,
      data: (tasks) => tasks.where((task) => task.id == item.taskId)
          .map((task) => task.name).firstOrNull,
    );
    final color = _priorityColor(context, item.priority);
    return Card(
      child: ListTile(
        leading: Icon(Icons.checklist_outlined, color: color),
        title: Text(item.title),
        subtitle: Text(
          '${_priorityLabel(item.priority)} • ${_statusLabel(item.status)}\n'
          '${item.location}${taskName == null ? '' : ' • $taskName'}\n'
          '${item.description}',
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<PunchListStatus>(
          tooltip: 'Update status',
          onSelected: (status) => _updateStatus(context, ref, status),
          itemBuilder: (_) => PunchListStatus.values.map((status) {
            return PopupMenuItem(value: status, child: Text(_statusLabel(status)));
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _updateStatus(
    BuildContext context,
    WidgetRef ref,
    PunchListStatus status,
  ) async {
    await ref.read(punchListActionsProvider).updateItem(
          PunchListItem(
            id: item.id,
            projectId: item.projectId,
            phaseId: item.phaseId,
            taskId: item.taskId,
            title: item.title,
            description: item.description,
            location: item.location,
            priority: item.priority,
            status: status,
            reportedDate: item.reportedDate,
          ),
        );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Snag marked ${_statusLabel(status).toLowerCase()}.')),
    );
  }
}

class _PunchForm extends ConsumerStatefulWidget {
  const _PunchForm({required this.projectId});
  final String projectId;

  @override
  ConsumerState<_PunchForm> createState() => _PunchFormState();
}

class _PunchFormState extends ConsumerState<_PunchForm> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _location = TextEditingController();
  final _description = TextEditingController();
  PunchListPriority _priority = PunchListPriority.medium;
  String? _phaseId;
  String? _taskId;

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phasesAsync = ref.watch(projectPhasesProvider(widget.projectId));
    final tasksAsync = ref.watch(projectTasksProvider(widget.projectId));
    return AlertDialog(
      title: const Text('Add snag / punch item'),
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
                _field(_location, 'Location'),
                const SizedBox(height: AppSpacing.sm),
                _PhaseDropdown(phasesAsync: phasesAsync, value: _phaseId,
                    onChanged: (value) => setState(() => _phaseId = value)),
                const SizedBox(height: AppSpacing.sm),
                tasksAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, _) => const Text('Unable to load tasks.'),
                  data: (tasks) => DropdownButtonFormField<String>(
                    initialValue: _taskId,
                    decoration: const InputDecoration(labelText: 'Task (optional)'),
                    items: tasks.map((task) => DropdownMenuItem(
                      value: task.id, child: Text(task.name),
                    )).toList(),
                    onChanged: (value) => setState(() => _taskId = value),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<PunchListPriority>(
                  initialValue: _priority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: PunchListPriority.values.map((priority) =>
                      DropdownMenuItem(value: priority, child: Text(_priorityLabel(priority)))).toList(),
                  onChanged: (value) { if (value != null) setState(() => _priority = value); },
                ),
                const SizedBox(height: AppSpacing.sm),
                _field(_description, 'Description', maxLines: 3),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }

  TextFormField _field(TextEditingController controller, String label, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
      validator: (value) => value == null || value.trim().isEmpty ? 'Enter $label.' : null,
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate() || _phaseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a phase before saving.')),
      );
      return;
    }
    Navigator.pop(context, PunchListItem(
      id: 'punch-${DateTime.now().microsecondsSinceEpoch}',
      projectId: widget.projectId,
      phaseId: _phaseId!,
      taskId: _taskId,
      title: _title.text.trim(),
      description: _description.text.trim(),
      location: _location.text.trim(),
      priority: _priority,
      status: PunchListStatus.open,
      reportedDate: DateTime.now(),
    ));
  }
}

class _PhaseDropdown extends StatelessWidget {
  const _PhaseDropdown({required this.phasesAsync, required this.value, required this.onChanged});
  final AsyncValue<List<ProjectPhase>> phasesAsync;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) => phasesAsync.when(
    loading: () => const LinearProgressIndicator(),
    error: (_, _) => const Text('Unable to load phases.'),
    data: (phases) => DropdownButtonFormField<String>(
      initialValue: value,
      decoration: const InputDecoration(labelText: 'Phase'),
      items: phases.map((phase) => DropdownMenuItem(value: phase.id, child: Text(phase.name))).toList(),
      onChanged: onChanged,
    ),
  );
}

Color _priorityColor(BuildContext context, PunchListPriority priority) {
  switch (priority) {
    case PunchListPriority.low: return Colors.blue;
    case PunchListPriority.medium: return Colors.orange;
    case PunchListPriority.high: return Colors.deepOrange;
    case PunchListPriority.critical: return Theme.of(context).colorScheme.error;
  }
}

String _priorityLabel(PunchListPriority priority) => switch (priority) {
  PunchListPriority.low => 'Low',
  PunchListPriority.medium => 'Medium',
  PunchListPriority.high => 'High',
  PunchListPriority.critical => 'Critical',
};

String _statusLabel(PunchListStatus status) => switch (status) {
  PunchListStatus.open => 'Open',
  PunchListStatus.inProgress => 'In progress',
  PunchListStatus.completed => 'Completed',
};
