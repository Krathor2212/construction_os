import '../../domain/entities/corrective_action.dart';
import '../../domain/repositories/corrective_action_repository.dart';

class MockCorrectiveActionRepository implements CorrectiveActionRepository {
  final List<CorrectiveAction> _actions = [
    CorrectiveAction(
      id: 'action-001',
      projectId: 'project-001',
      phaseId: 'phase-001',
      taskId: 'task-001',
      title: 'Trim and compact excavation edge',
      description: 'Correct the uneven edge before the next inspection.',
      responsiblePerson: 'Site supervisor',
      dueDate: DateTime(2026, 10, 2),
      priority: CorrectiveActionPriority.high,
      status: CorrectiveActionStatus.inProgress,
      createdDate: DateTime(2026, 9, 25),
    ),
  ];

  @override
  Future<List<CorrectiveAction>> getActions({
    required String projectId,
  }) async {
    return _actions.where((action) => action.projectId == projectId).toList()
      ..sort((a, b) => b.createdDate.compareTo(a.createdDate));
  }

  @override
  Future<CorrectiveAction> createAction(CorrectiveAction action) async {
    _actions.add(action);
    return action;
  }

  @override
  Future<CorrectiveAction> updateAction(CorrectiveAction action) async {
    final index = _actions.indexWhere((item) => item.id == action.id);
    if (index == -1) {
      throw StateError('Corrective action ${action.id} not found.');
    }
    _actions[index] = action;
    return action;
  }
}
