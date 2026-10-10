class MaterialReceipt {
  const MaterialReceipt({
    required this.id,
    required this.projectId,
    required this.materialId,
    this.deliveryId,
    required this.quantity,
    required this.unit,
    required this.receivedDate,
    required this.receivedBy,
    this.notes,
  });

  final String id;
  final String projectId;
  final String materialId;
  final String? deliveryId;
  final double quantity;
  final String unit;
  final DateTime receivedDate;
  final String receivedBy;
  final String? notes;
}
