import '../entities/purchase_order_item.dart';

abstract interface class PurchaseOrderItemRepository {
  Future<List<PurchaseOrderItem>> getItems(
    String purchaseOrderId,
  );

  Future<PurchaseOrderItem> getItem(
    String id,
  );

  Future<PurchaseOrderItem> createItem(
    PurchaseOrderItem item,
  );

  Future<PurchaseOrderItem> updateItem(
    PurchaseOrderItem item,
  );

  Future<void> deleteItem(
    String id,
  );
}