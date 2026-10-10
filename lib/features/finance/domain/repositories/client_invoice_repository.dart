import '../entities/client_invoice.dart';

abstract interface class ClientInvoiceRepository {
  Future<List<ClientInvoice>> getInvoices({required String projectId});
  Future<ClientInvoice> createInvoice(ClientInvoice invoice);
}
