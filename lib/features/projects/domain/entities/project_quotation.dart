class ProjectQuotation {
  const ProjectQuotation({
    required this.id,
    required this.projectId,
    required this.quotationNumber,
    required this.supplierName,
    required this.quotationDate,
    this.validUntil,
    this.subtotal = 0,
    this.tax = 0,
    this.discount = 0,
    this.notes,
    this.status = ProjectQuotationStatus.draft,
  });

  final String id;
  final String projectId;
  final String quotationNumber;
  final String supplierName;
  final DateTime quotationDate;
  final DateTime? validUntil;
  final double subtotal;
  final double tax;
  final double discount;
  final String? notes;
  final ProjectQuotationStatus status;

  double get total => subtotal + tax - discount;
}

enum ProjectQuotationStatus {
  draft,
  sent,
  accepted,
  rejected,
  expired,
}