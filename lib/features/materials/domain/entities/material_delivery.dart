enum MaterialDeliveryStatus {
  expected,
  inTransit,
  partiallyReceived,
  received,
  cancelled,
}

class MaterialDelivery {
  const MaterialDelivery({
    required this.id,
    required this.projectId,
    required this.materialRequirementId,
    required this.materialId,
    required this.quantity,
    required this.unit,
    required this.deliveryDate,
    required this.supplierName,
    required this.referenceNumber,
    required this.status,
    this.purchaseOrderId,
    this.notes,
  });

  final String id;
  final String projectId;
  final String materialRequirementId;
  final String materialId;
  final double quantity;
  final String unit;
  final DateTime deliveryDate;
  final String supplierName;
  final String referenceNumber;
  final MaterialDeliveryStatus status;
  final String? purchaseOrderId;
  final String? notes;
}
