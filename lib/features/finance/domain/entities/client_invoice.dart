enum ClientInvoiceStatus {
  draft,
  issued,
  partiallyPaid,
  paid,
  overdue,
  cancelled,
}

class ClientInvoice {
  const ClientInvoice({
    required this.id,
    required this.projectId,
    required this.invoiceNumber,
    required this.milestoneName,
    required this.issueDate,
    required this.dueDate,
    required this.amount,
    this.paidAmount = 0,
    this.status = ClientInvoiceStatus.draft,
    this.notes,
  });

  final String id;
  final String projectId;
  final String invoiceNumber;
  final String milestoneName;
  final DateTime issueDate;
  final DateTime dueDate;
  final double amount;
  final double paidAmount;
  final ClientInvoiceStatus status;
  final String? notes;

  double get outstandingAmount => amount - paidAmount;
}
