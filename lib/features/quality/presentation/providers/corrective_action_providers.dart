import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_corrective_action_repository.dart';
import '../../domain/entities/corrective_action.dart';
import '../../domain/repositories/corrective_action_repository.dart';

final correctiveActionRepositoryProvider =
    Provider<CorrectiveActionRepository>((ref) {
  return MockCorrectiveActionRepository();
});

final projectCorrectiveActionsProvider =
    FutureProvider.family<List<CorrectiveAction>, String>((ref, projectId) {
  return ref
      .watch(correctiveActionRepositoryProvider)
      .getActions(projectId: projectId);
});

final correctiveActionActionsProvider =
    Provider<CorrectiveActionActions>((ref) {
  return CorrectiveActionActions(ref);
});

class CorrectiveActionActions {
  CorrectiveActionActions(this._ref);

  final Ref _ref;

  Future<CorrectiveAction> createAction(CorrectiveAction action) async {
    final created =
        await _ref.read(correctiveActionRepositoryProvider).createAction(action);
    _ref.invalidate(projectCorrectiveActionsProvider(action.projectId));
    return created;
  }

  Future<CorrectiveAction> updateAction(CorrectiveAction action) async {
    final updated =
        await _ref.read(correctiveActionRepositoryProvider).updateAction(action);
    _ref.invalidate(projectCorrectiveActionsProvider(action.projectId));
    return updated;
  }
}
