import '../entities/punch_list_item.dart';

abstract interface class PunchListRepository {
  Future<List<PunchListItem>> getItems({required String projectId});
  Future<PunchListItem> createItem(PunchListItem item);
  Future<PunchListItem> updateItem(PunchListItem item);
}
