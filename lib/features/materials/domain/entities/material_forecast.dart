class MaterialForecast {
  const MaterialForecast({
    required this.materialId,
    required this.unit,
    required this.requiredQuantity,
    required this.receivedQuantity,
    required this.availableQuantity,
    required this.projectedShortfall,
  });

  final String materialId;
  final String unit;
  final double requiredQuantity;
  final double receivedQuantity;
  final double availableQuantity;
  final double projectedShortfall;

  bool get isCovered => projectedShortfall <= 0;
}
