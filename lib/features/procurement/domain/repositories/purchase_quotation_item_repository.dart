import '../entities/purchase_quotation_item.dart';

abstract interface class PurchaseQuotationItemRepository {
  Future<List<PurchaseQuotationItem>> getItems(
    String quotationId,
  );

  Future<PurchaseQuotationItem> getItem(
    String id,
  );

  Future<PurchaseQuotationItem> createItem(
    PurchaseQuotationItem item,
  );

  Future<PurchaseQuotationItem> updateItem(
    PurchaseQuotationItem item,
  );

  Future<void> deleteItem(
    String id,
  );
}