import '../../domain/entities/material_receipt.dart';
import '../../domain/repositories/material_receipt_repository.dart';

class MockMaterialReceiptRepository implements MaterialReceiptRepository {
  final List<MaterialReceipt> _receipts = [
    MaterialReceipt(
      id: 'receipt-001',
      projectId: 'project-001',
      materialId: 'material-001',
      deliveryId: 'delivery-001',
      quantity: 250,
      unit: 'bag',
      receivedDate: DateTime(2026, 9, 28),
      receivedBy: 'Site Engineer',
      notes: 'Quantity and packaging verified at site gate.',
    ),
  ];

  @override
  Future<List<MaterialReceipt>> getReceipts({required String projectId}) async {
    return _receipts.where((receipt) => receipt.projectId == projectId).toList()
      ..sort((a, b) => b.receivedDate.compareTo(a.receivedDate));
  }

  @override
  Future<MaterialReceipt> createReceipt(MaterialReceipt receipt) async {
    _receipts.add(receipt);
    return receipt;
  }
}
