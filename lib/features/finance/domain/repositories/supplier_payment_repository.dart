import '../entities/supplier_payment.dart';

abstract interface class SupplierPaymentRepository {
  Future<List<SupplierPayment>> getPayments({required String projectId});
  Future<SupplierPayment> createPayment(SupplierPayment payment);
}
