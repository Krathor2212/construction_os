class SupplierPayment {
  const SupplierPayment({
    required this.id,
    required this.projectId,
    required this.supplierBillId,
    required this.supplierName,
    required this.paymentDate,
    required this.amount,
    required this.paymentMethod,
    required this.reference,
    this.notes,
  });

  final String id;
  final String projectId;
  final String supplierBillId;
  final String supplierName;
  final DateTime paymentDate;
  final double amount;
  final String paymentMethod;
  final String reference;
  final String? notes;
}
