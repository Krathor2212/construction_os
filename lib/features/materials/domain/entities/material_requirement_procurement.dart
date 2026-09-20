class MaterialRequirementProcurement {
  const MaterialRequirementProcurement({
    required this.id,
    required this.materialRequirementId,
    required this.purchaseOrderId,
    required this.purchaseOrderItemId,
    required this.quantity,
    this.notes,
  });

  final String id;
  final String materialRequirementId;
  final String purchaseOrderId;
  final String purchaseOrderItemId;
  final double quantity;
  final String? notes;
}