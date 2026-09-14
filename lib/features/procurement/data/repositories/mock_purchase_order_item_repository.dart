import '../../domain/entities/purchase_order_item.dart';
import '../../domain/repositories/purchase_order_item_repository.dart';

class MockPurchaseOrderItemRepository
    implements PurchaseOrderItemRepository {
  final List<PurchaseOrderItem> _items = [
    PurchaseOrderItem(
      id: 'purchase-order-item-001',
      purchaseOrderId: 'purchase-order-001',
      materialId: 'material-002',
      description: 'TMT Steel 12mm',
      quantity: 2500,
      unit: 'kg',
      unitRate: 62,
      taxRate: 18,
      notes: 'Fe 500 grade reinforcement steel.',
    ),
    PurchaseOrderItem(
      id: 'purchase-order-item-002',
      purchaseOrderId: 'purchase-order-001',
      materialId: 'material-002',
      description: 'TMT Steel 16mm',
      quantity: 1500,
      unit: 'kg',
      unitRate: 64,
      taxRate: 18,
    ),
    PurchaseOrderItem(
      id: 'purchase-order-item-003',
      purchaseOrderId: 'purchase-order-002',
      materialId: 'material-001',
      description: 'OPC Cement 53 Grade',
      quantity: 500,
      unit: 'bag',
      unitRate: 430,
      taxRate: 18,
      notes: 'Fresh stock required for site delivery.',
    ),
    PurchaseOrderItem(
      id: 'purchase-order-item-004',
      purchaseOrderId: 'purchase-order-002',
      materialId: 'material-003',
      description: 'River Sand',
      quantity: 30,
      unit: 'm³',
      unitRate: 1850,
      taxRate: 5,
    ),
    PurchaseOrderItem(
      id: 'purchase-order-item-005',
      purchaseOrderId: 'purchase-order-003',
      materialId: 'material-005',
      description: '20mm Aggregate',
      quantity: 100,
      unit: 'm³',
      unitRate: 1650,
      taxRate: 5,
    ),
  ];

  @override
  Future<List<PurchaseOrderItem>> getItems(
    String purchaseOrderId,
  ) async {
    return List.unmodifiable(
      _items.where(
        (item) => item.purchaseOrderId == purchaseOrderId,
      ),
    );
  }

  @override
  Future<PurchaseOrderItem> getItem(
    String id,
  ) async {
    return _items.firstWhere(
      (item) => item.id == id,
    );
  }

  @override
  Future<PurchaseOrderItem> createItem(
    PurchaseOrderItem item,
  ) async {
    _items.add(item);
    return item;
  }

  @override
  Future<PurchaseOrderItem> updateItem(
    PurchaseOrderItem item,
  ) async {
    final index = _items.indexWhere(
      (existing) => existing.id == item.id,
    );

    if (index == -1) {
      throw StateError(
        'Purchase order item not found: ${item.id}',
      );
    }

    _items[index] = item;
    return item;
  }

  @override
  Future<void> deleteItem(String id) async {
    final index = _items.indexWhere(
      (item) => item.id == id,
    );

    if (index == -1) {
      throw StateError(
        'Purchase order item not found: $id',
      );
    }

    _items.removeAt(index);
  }
}