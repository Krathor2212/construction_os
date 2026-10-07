import '../../domain/entities/punch_list_item.dart';
import '../../domain/repositories/punch_list_repository.dart';

class MockPunchListRepository implements PunchListRepository {
  final List<PunchListItem> _items = [
    PunchListItem(
      id: 'punch-001',
      projectId: 'project-001',
      phaseId: 'phase-001',
      taskId: 'task-001',
      title: 'Trim north excavation edge',
      description: 'Make the edge straight and ready for the next activity.',
      location: 'North foundation edge',
      priority: PunchListPriority.high,
      status: PunchListStatus.open,
      reportedDate: DateTime(2026, 9, 25),
    ),
  ];

  @override
  Future<List<PunchListItem>> getItems({required String projectId}) async {
    return _items.where((item) => item.projectId == projectId).toList()
      ..sort((a, b) => b.reportedDate.compareTo(a.reportedDate));
  }

  @override
  Future<PunchListItem> createItem(PunchListItem item) async {
    _items.add(item);
    return item;
  }

  @override
  Future<PunchListItem> updateItem(PunchListItem item) async {
    final index = _items.indexWhere((existing) => existing.id == item.id);
    if (index == -1) throw StateError('Punch-list item ${item.id} not found.');
    _items[index] = item;
    return item;
  }
}
