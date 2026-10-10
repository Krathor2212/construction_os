enum SupplierBillStatus {
  draft,
  submitted,
  partiallyPaid,
  paid,
  overdue,
  cancelled,
}

class SupplierBill {
  const SupplierBill({
    required this.id,
    required this.projectId,
    required this.supplierName,
    required this.billNumber,
    required this.billDate,
    required this.dueDate,
    required this.amount,
    this.paidAmount = 0,
    this.status = SupplierBillStatus.draft,
    this.notes,
  });

  final String id;
  final String projectId;
  final String supplierName;
  final String billNumber;
  final DateTime billDate;
  final DateTime dueDate;
  final double amount;
  final double paidAmount;
  final SupplierBillStatus status;
  final String? notes;

  double get outstandingAmount => amount - paidAmount;
}
