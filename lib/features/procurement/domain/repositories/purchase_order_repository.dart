import '../entities/purchase_order.dart';

abstract interface class PurchaseOrderRepository {
  Future<List<PurchaseOrder>> getPurchaseOrders(
    String projectId,
  );

  Future<PurchaseOrder> getPurchaseOrder(
    String id,
  );

  Future<PurchaseOrder> createPurchaseOrder(
    PurchaseOrder order,
  );

  Future<PurchaseOrder> updatePurchaseOrder(
    PurchaseOrder order,
  );

  Future<void> archivePurchaseOrder(
    String id,
  );
}