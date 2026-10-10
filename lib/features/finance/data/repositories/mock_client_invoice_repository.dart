import '../../domain/entities/client_invoice.dart';
import '../../domain/repositories/client_invoice_repository.dart';

class MockClientInvoiceRepository implements ClientInvoiceRepository {
  final List<ClientInvoice> _invoices = [
    ClientInvoice(
      id: 'client-invoice-001',
      projectId: 'project-001',
      invoiceNumber: 'INV-1001',
      milestoneName: 'Foundation completion',
      issueDate: DateTime(2026, 10, 1),
      dueDate: DateTime(2026, 10, 15),
      amount: 350000,
      status: ClientInvoiceStatus.issued,
    ),
  ];

  @override
  Future<List<ClientInvoice>> getInvoices({required String projectId}) async =>
      _invoices.where((invoice) => invoice.projectId == projectId).toList()
        ..sort((a, b) => b.issueDate.compareTo(a.issueDate));

  @override
  Future<ClientInvoice> createInvoice(ClientInvoice invoice) async {
    _invoices.add(invoice);
    return invoice;
  }
}
