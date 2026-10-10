import '../entities/supplier_bill.dart';

abstract interface class SupplierBillRepository {
  Future<List<SupplierBill>> getBills({required String projectId});
  Future<SupplierBill> createBill(SupplierBill bill);
}
