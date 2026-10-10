import '../../domain/entities/supplier_payment.dart';
import '../../domain/repositories/supplier_payment_repository.dart';

class MockSupplierPaymentRepository implements SupplierPaymentRepository {
  final List<SupplierPayment> _payments = [
    SupplierPayment(
      id: 'supplier-payment-001',
      projectId: 'project-001',
      supplierBillId: 'supplier-bill-001',
      supplierName: 'BuildMart Suppliers',
      paymentDate: DateTime(2026, 10, 5),
      amount: 50000,
      paymentMethod: 'Bank transfer',
      reference: 'UTR-1001',
    ),
  ];

  @override
  Future<List<SupplierPayment>> getPayments({
    required String projectId,
  }) async =>
      _payments.where((payment) => payment.projectId == projectId).toList()
        ..sort((a, b) => b.paymentDate.compareTo(a.paymentDate));

  @override
  Future<SupplierPayment> createPayment(SupplierPayment payment) async {
    _payments.add(payment);
    return payment;
  }
}
