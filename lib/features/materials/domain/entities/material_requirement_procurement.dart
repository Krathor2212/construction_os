class MaterialRequirementProcurement {
  const MaterialRequirementProcurement({
    required this.id,
    required this.materialRequirementId,
    required this.purchaseOrderId,
    required this.quantity,
    this.notes,
  });

  final String id;
  final String materialRequirementId;
  final String purchaseOrderId;
  final double quantity;
  final String? notes;
}