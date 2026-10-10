import 'package:flutter_test/flutter_test.dart';

import 'package:construction_os/features/finance/data/repositories/mock_client_invoice_repository.dart';
import 'package:construction_os/features/finance/data/repositories/mock_supplier_bill_repository.dart';
import 'package:construction_os/features/finance/data/repositories/mock_supplier_payment_repository.dart';

void main() {
  test('returns project supplier bills', () async {
    final bills = await MockSupplierBillRepository().getBills(
      projectId: 'project-001',
    );
    expect(bills, hasLength(1));
    expect(bills.single.outstandingAmount, 125000);
  });

  test('returns project supplier payments', () async {
    final payments = await MockSupplierPaymentRepository().getPayments(
      projectId: 'project-001',
    );
    expect(payments, hasLength(1));
    expect(payments.single.amount, 50000);
  });

  test('returns project client invoices', () async {
    final invoices = await MockClientInvoiceRepository().getInvoices(
      projectId: 'project-001',
    );
    expect(invoices, hasLength(1));
    expect(invoices.single.milestoneName, 'Foundation completion');
  });
}
