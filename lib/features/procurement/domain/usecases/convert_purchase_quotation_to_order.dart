import '../entities/purchase_order.dart';
import '../entities/purchase_order_item.dart';
import '../entities/purchase_quotation.dart';
import '../repositories/purchase_order_item_repository.dart';
import '../repositories/purchase_order_repository.dart';
import '../repositories/purchase_quotation_item_repository.dart';
import '../repositories/purchase_quotation_repository.dart';

class ConvertPurchaseQuotationToOrder {
  const ConvertPurchaseQuotationToOrder({
    required this.purchaseQuotationRepository,
    required this.purchaseQuotationItemRepository,
    required this.purchaseOrderRepository,
    required this.purchaseOrderItemRepository,
  });

  final PurchaseQuotationRepository purchaseQuotationRepository;
  final PurchaseQuotationItemRepository purchaseQuotationItemRepository;
  final PurchaseOrderRepository purchaseOrderRepository;
  final PurchaseOrderItemRepository purchaseOrderItemRepository;

  Future<PurchaseOrder> execute({
    required String quotationId,
    required String poNumber,
    DateTime? orderDate,
    DateTime? expectedDeliveryDate,
  }) async {
    final quotation =
        await purchaseQuotationRepository.getPurchaseQuotation(
      quotationId,
    );

    if (quotation.isArchived) {
      throw StateError(
        'Cannot convert an archived purchase quotation.',
      );
    }

    if (quotation.status != PurchaseQuotationStatus.accepted) {
      throw StateError(
        'Only an accepted purchase quotation can be converted '
        'to a purchase order.',
      );
    }

    // Prevent the same quotation from being converted more than once.
    final existingOrders =
        await purchaseOrderRepository.getPurchaseOrders(
      quotation.projectId,
    );

    final alreadyConverted = existingOrders.any(
      (order) =>
          !order.isArchived &&
          order.purchaseQuotationId == quotation.id,
    );

    if (alreadyConverted) {
      throw StateError(
        'This purchase quotation has already been converted '
        'to a purchase order.',
      );
    }

    final quotationItems =
        await purchaseQuotationItemRepository.getItems(
      quotationId,
    );

    if (quotationItems.isEmpty) {
      throw StateError(
        'Cannot convert a purchase quotation without line items.',
      );
    }

    // PO subtotal and tax are derived from PO line items.
    // Discount and delivery charges remain quotation-level values.
    final order = PurchaseOrder(
      id:
          'purchase-order-${DateTime.now().microsecondsSinceEpoch}',
      projectId: quotation.projectId,
      supplierId: quotation.supplierId,
      purchaseQuotationId: quotation.id,
      poNumber: poNumber,
      orderDate: orderDate ?? DateTime.now(),
      expectedDeliveryDate: expectedDeliveryDate,
      subtotal: 0,
      tax: 0,
      discount: quotation.discount,
      deliveryCharges: quotation.deliveryCharges,
      paymentTerms: quotation.paymentTerms,
      deliveryTerms: quotation.deliveryTerms,
      notes: quotation.notes,
      status: PurchaseOrderStatus.draft,
    );

    final createdOrder =
        await purchaseOrderRepository.createPurchaseOrder(
      order,
    );

    for (final quotationItem in quotationItems) {
      final orderItem = PurchaseOrderItem(
        id:
            'purchase-order-item-'
            '${DateTime.now().microsecondsSinceEpoch}-'
            '${quotationItem.id}',
        purchaseOrderId: createdOrder.id,
        materialId: quotationItem.materialId,
        description: quotationItem.description,
        quantity: quotationItem.quantity,
        unit: quotationItem.unit,
        unitRate: quotationItem.unitRate,
        taxRate: quotationItem.taxRate,
        notes: quotationItem.notes,
      );

      await purchaseOrderItemRepository.createItem(
        orderItem,
      );
    }

    return createdOrder;
  }
}
