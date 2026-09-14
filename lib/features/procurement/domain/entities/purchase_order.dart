class PurchaseOrder {
  const PurchaseOrder({
    required this.id,
    required this.projectId,
    required this.supplierId,
    required this.poNumber,
    required this.orderDate,
    this.purchaseQuotationId,
    this.expectedDeliveryDate,
    this.subtotal = 0,
    this.tax = 0,
    this.discount = 0,
    this.deliveryCharges = 0,
    this.paymentTerms,
    this.deliveryTerms,
    this.notes,
    this.status = PurchaseOrderStatus.draft,
    this.isArchived = false,
  });

  final String id;
  final String projectId;
  final String supplierId;

  /// Optional quotation from which this purchase order originated.
  final String? purchaseQuotationId;

  final String poNumber;

  final DateTime orderDate;
  final DateTime? expectedDeliveryDate;

  final double subtotal;
  final double tax;
  final double discount;
  final double deliveryCharges;

  final String? paymentTerms;
  final String? deliveryTerms;
  final String? notes;

  final PurchaseOrderStatus status;

  final bool isArchived;

  double get total =>
      subtotal +
      tax +
      deliveryCharges -
      discount;
}

enum PurchaseOrderStatus {
  draft,
  issued,
  partiallyReceived,
  received,
  cancelled,
  closed,
}
