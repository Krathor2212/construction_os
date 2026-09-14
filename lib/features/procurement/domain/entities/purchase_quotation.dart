class PurchaseQuotation {
  const PurchaseQuotation({
    required this.id,
    required this.projectId,
    required this.supplierId,
    required this.quotationNumber,
    required this.quotationDate,
    this.validUntil,
    this.subtotal = 0,
    this.tax = 0,
    this.discount = 0,
    this.deliveryCharges = 0,
    this.paymentTerms,
    this.deliveryTerms,
    this.notes,
    this.status = PurchaseQuotationStatus.draft,
    this.isArchived = false,
  });

  final String id;
  final String projectId;
  final String supplierId;

  final String quotationNumber;

  final DateTime quotationDate;
  final DateTime? validUntil;

  final double subtotal;
  final double tax;
  final double discount;
  final double deliveryCharges;

  final String? paymentTerms;
  final String? deliveryTerms;
  final String? notes;

  final PurchaseQuotationStatus status;

  /// Archived quotations are retained for procurement history
  /// but excluded from active procurement workflows.
  final bool isArchived;

  double get total =>
      subtotal +
      tax +
      deliveryCharges -
      discount;
}

enum PurchaseQuotationStatus {
  draft,
  received,
  underReview,
  accepted,
  rejected,
  expired,
}