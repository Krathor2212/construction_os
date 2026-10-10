import '../../domain/entities/supplier_bill.dart';
import '../../domain/repositories/supplier_bill_repository.dart';

class MockSupplierBillRepository implements SupplierBillRepository {
  final List<SupplierBill> _bills = [
    SupplierBill(
      id: 'supplier-bill-001',
      projectId: 'project-001',
      supplierName: 'BuildMart Suppliers',
      billNumber: 'BILL-1001',
      billDate: DateTime(2026, 9, 28),
      dueDate: DateTime(2026, 10, 28),
      amount: 125000,
      status: SupplierBillStatus.submitted,
    ),
  ];

  @override
  Future<List<SupplierBill>> getBills({required String projectId}) async =>
      _bills.where((bill) => bill.projectId == projectId).toList()
        ..sort((a, b) => b.billDate.compareTo(a.billDate));

  @override
  Future<SupplierBill> createBill(SupplierBill bill) async {
    _bills.add(bill);
    return bill;
  }
}
