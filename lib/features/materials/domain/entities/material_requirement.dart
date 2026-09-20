class MaterialRequirement {
  const MaterialRequirement({
    required this.id,
    required this.projectId,
    this.phaseId,
    required this.materialId,
    required this.quantity,
    required this.unit,
    this.requiredByDate,
    this.notes,
    this.status = MaterialRequirementStatus.planned,
    this.isArchived = false,
  });

  final String id;
  final String projectId;
  final String? phaseId;
  final String materialId;
  final double quantity;
  final String unit;
  final DateTime? requiredByDate;
  final String? notes;
  final MaterialRequirementStatus status;
  final bool isArchived;
}

enum MaterialRequirementStatus {
  planned,
  partiallyProcured,
  procured,
  completed,
  cancelled,
}