import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_punch_list_repository.dart';
import '../../domain/entities/punch_list_item.dart';
import '../../domain/repositories/punch_list_repository.dart';

final punchListRepositoryProvider = Provider<PunchListRepository>((ref) {
  return MockPunchListRepository();
});

final projectPunchListProvider =
    FutureProvider.family<List<PunchListItem>, String>((ref, projectId) async {
  return ref.watch(punchListRepositoryProvider).getItems(projectId: projectId);
});

final punchListActionsProvider = Provider<PunchListActions>((ref) {
  return PunchListActions(ref);
});

class PunchListActions {
  PunchListActions(this._ref);

  final Ref _ref;

  Future<PunchListItem> createItem(PunchListItem item) async {
    final created = await _ref.read(punchListRepositoryProvider).createItem(item);
    _ref.invalidate(projectPunchListProvider(item.projectId));
    return created;
  }

  Future<PunchListItem> updateItem(PunchListItem item) async {
    final updated = await _ref.read(punchListRepositoryProvider).updateItem(item);
    _ref.invalidate(projectPunchListProvider(item.projectId));
    return updated;
  }
}
