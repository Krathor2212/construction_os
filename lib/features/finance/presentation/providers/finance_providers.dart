import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_client_invoice_repository.dart';
import '../../data/repositories/mock_supplier_bill_repository.dart';
import '../../data/repositories/mock_supplier_payment_repository.dart';
import '../../domain/entities/client_invoice.dart';
import '../../domain/entities/supplier_bill.dart';
import '../../domain/entities/supplier_payment.dart';
import '../../domain/repositories/client_invoice_repository.dart';
import '../../domain/repositories/supplier_bill_repository.dart';
import '../../domain/repositories/supplier_payment_repository.dart';

final supplierBillRepositoryProvider = Provider<SupplierBillRepository>(
  (ref) => MockSupplierBillRepository(),
);
final supplierPaymentRepositoryProvider = Provider<SupplierPaymentRepository>(
  (ref) => MockSupplierPaymentRepository(),
);
final clientInvoiceRepositoryProvider = Provider<ClientInvoiceRepository>(
  (ref) => MockClientInvoiceRepository(),
);

final projectSupplierBillsProvider =
    FutureProvider.family<List<SupplierBill>, String>((ref, projectId) {
      return ref
          .watch(supplierBillRepositoryProvider)
          .getBills(projectId: projectId);
    });
final projectSupplierPaymentsProvider =
    FutureProvider.family<List<SupplierPayment>, String>((ref, projectId) {
      return ref
          .watch(supplierPaymentRepositoryProvider)
          .getPayments(projectId: projectId);
    });
final projectClientInvoicesProvider =
    FutureProvider.family<List<ClientInvoice>, String>((ref, projectId) {
      return ref
          .watch(clientInvoiceRepositoryProvider)
          .getInvoices(projectId: projectId);
    });

final financeActionsProvider = Provider<FinanceActions>((ref) {
  return FinanceActions(ref);
});

class FinanceActions {
  FinanceActions(this._ref);

  final Ref _ref;

  Future<SupplierBill> createBill(SupplierBill bill) async {
    final result = await _ref
        .read(supplierBillRepositoryProvider)
        .createBill(bill);
    _ref.invalidate(projectSupplierBillsProvider(bill.projectId));
    return result;
  }

  Future<SupplierPayment> createPayment(SupplierPayment payment) async {
    final result = await _ref
        .read(supplierPaymentRepositoryProvider)
        .createPayment(payment);
    _ref.invalidate(projectSupplierPaymentsProvider(payment.projectId));
    return result;
  }

  Future<ClientInvoice> createInvoice(ClientInvoice invoice) async {
    final result = await _ref
        .read(clientInvoiceRepositoryProvider)
        .createInvoice(invoice);
    _ref.invalidate(projectClientInvoicesProvider(invoice.projectId));
    return result;
  }
}
