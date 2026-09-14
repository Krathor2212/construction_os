class PurchaseOrderItem {
  const PurchaseOrderItem({
    required this.id,
    required this.purchaseOrderId,
    required this.materialId,
    required this.description,
    required this.quantity,
    required this.unit,
    required this.unitRate,
    this.taxRate = 0,
    this.notes,
  });

  final String id;
  final String purchaseOrderId;

  /// References the material master.
  final String materialId;

  final String description;

  final double quantity;
  final String unit;

  final double unitRate;
  final double taxRate;

  final String? notes;

  double get subtotal => quantity * unitRate;

  double get tax => subtotal * (taxRate / 100);

  double get total => subtotal + tax;
}