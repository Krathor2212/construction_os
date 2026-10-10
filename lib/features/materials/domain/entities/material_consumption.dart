class MaterialConsumption {
  const MaterialConsumption({
    required this.id,
    required this.projectId,
    required this.materialId,
    this.phaseId,
    this.taskId,
    required this.quantity,
    required this.unit,
    required this.consumedDate,
    required this.issuedTo,
    this.notes,
  });

  final String id;
  final String projectId;
  final String materialId;
  final String? phaseId;
  final String? taskId;
  final double quantity;
  final String unit;
  final DateTime consumedDate;
  final String issuedTo;
  final String? notes;
}
