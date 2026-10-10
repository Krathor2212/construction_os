import '../entities/material_receipt.dart';

abstract interface class MaterialReceiptRepository {
  Future<List<MaterialReceipt>> getReceipts({required String projectId});
  Future<MaterialReceipt> createReceipt(MaterialReceipt receipt);
}
