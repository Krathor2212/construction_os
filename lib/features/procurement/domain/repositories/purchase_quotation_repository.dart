import '../entities/purchase_quotation.dart';

abstract interface class PurchaseQuotationRepository {
  Future<List<PurchaseQuotation>> getPurchaseQuotations(
    String projectId,
  );

  Future<PurchaseQuotation> getPurchaseQuotation(
    String id,
  );

  Future<PurchaseQuotation> createPurchaseQuotation(
    PurchaseQuotation quotation,
  );

  Future<PurchaseQuotation> updatePurchaseQuotation(
    PurchaseQuotation quotation,
  );

  Future<void> archivePurchaseQuotation(
    String id,
  );
}