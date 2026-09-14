import '../../domain/entities/purchase_order.dart';
import '../../domain/repositories/purchase_order_repository.dart';

class MockPurchaseOrderRepository
    implements PurchaseOrderRepository {
  final List<PurchaseOrder> _orders = [
    PurchaseOrder(
      id: 'purchase-order-001',
      projectId: 'project-001',
      supplierId: 'supplier-001',
      poNumber: 'PO-2026-001',
      orderDate: DateTime(2026, 8, 12),
      expectedDeliveryDate: DateTime(2026, 8, 16),
      subtotal: 251000,
      tax: 45180,
      discount: 10000,
      deliveryCharges: 5000,
      paymentTerms: '30 days credit',
      deliveryTerms: 'Delivery within 3 working days',
      notes: 'Steel order for structure phase.',
      status: PurchaseOrderStatus.issued,
    ),
    PurchaseOrder(
      id: 'purchase-order-002',
      projectId: 'project-001',
      supplierId: 'supplier-002',
      poNumber: 'PO-2026-002',
      orderDate: DateTime(2026, 8, 14),
      expectedDeliveryDate: DateTime(2026, 8, 17),
      subtotal: 270500,
      tax: 41475,
      discount: 5000,
      deliveryCharges: 3000,
      paymentTerms: '15 days credit',
      deliveryTerms: 'Delivery within 2 working days',
      notes: 'Cement and sand order.',
      status: PurchaseOrderStatus.partiallyReceived,
    ),
    PurchaseOrder(
      id: 'purchase-order-003',
      projectId: 'project-002',
      supplierId: 'supplier-003',
      poNumber: 'PO-2026-003',
      orderDate: DateTime(2026, 9, 5),
      expectedDeliveryDate: DateTime(2026, 9, 10),
      subtotal: 165000,
      tax: 8250,
      discount: 0,
      deliveryCharges: 7500,
      paymentTerms: '30 days credit',
      deliveryTerms: 'Scheduled delivery',
      notes: 'Aggregate order for commercial building.',
      status: PurchaseOrderStatus.draft,
    ),
  ];

  @override
  Future<List<PurchaseOrder>> getPurchaseOrders(
    String projectId,
  ) async {
    return List.unmodifiable(
      _orders.where(
        (order) =>
            order.projectId == projectId &&
            !order.isArchived,
      ),
    );
  }

  @override
  Future<PurchaseOrder> getPurchaseOrder(
    String id,
  ) async {
    return _orders.firstWhere(
      (order) => order.id == id,
    );
  }

  @override
  Future<PurchaseOrder> createPurchaseOrder(
    PurchaseOrder order,
  ) async {
    _orders.add(order);
    return order;
  }

  @override
  Future<PurchaseOrder> updatePurchaseOrder(
    PurchaseOrder order,
  ) async {
    final index = _orders.indexWhere(
      (existing) => existing.id == order.id,
    );

    if (index == -1) {
      throw StateError(
        'Purchase order not found: ${order.id}',
      );
    }

    _orders[index] = order;
    return order;
  }

  @override
  Future<void> archivePurchaseOrder(
    String id,
  ) async {
    final index = _orders.indexWhere(
      (order) => order.id == id,
    );

    if (index == -1) {
      throw StateError(
        'Purchase order not found: $id',
      );
    }

    final order = _orders[index];

    _orders[index] = PurchaseOrder(
      id: order.id,
      projectId: order.projectId,
      supplierId: order.supplierId,
      poNumber: order.poNumber,
      orderDate: order.orderDate,
      expectedDeliveryDate: order.expectedDeliveryDate,
      subtotal: order.subtotal,
      tax: order.tax,
      discount: order.discount,
      deliveryCharges: order.deliveryCharges,
      paymentTerms: order.paymentTerms,
      deliveryTerms: order.deliveryTerms,
      notes: order.notes,
      status: order.status,
      isArchived: true,
    );
  }
}