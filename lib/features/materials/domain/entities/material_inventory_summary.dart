class MaterialInventorySummary {
  const MaterialInventorySummary({
    required this.materialId,
    required this.unit,
    required this.receivedQuantity,
    required this.consumedQuantity,
    required this.wastedQuantity,
  });

  final String materialId;
  final String unit;
  final double receivedQuantity;
  final double consumedQuantity;
  final double wastedQuantity;

  double get availableQuantity =>
      receivedQuantity - consumedQuantity - wastedQuantity;
}
