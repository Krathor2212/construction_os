enum MaterialWastageReason { damage, excess, spoilage, qualityIssue, other }

class MaterialWastage {
  const MaterialWastage({
    required this.id,
    required this.projectId,
    required this.materialId,
    required this.quantity,
    required this.unit,
    required this.wastedDate,
    required this.reason,
    required this.reportedBy,
    this.notes,
  });

  final String id;
  final String projectId;
  final String materialId;
  final double quantity;
  final String unit;
  final DateTime wastedDate;
  final MaterialWastageReason reason;
  final String reportedBy;
  final String? notes;
}
