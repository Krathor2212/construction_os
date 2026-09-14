import '../../domain/entities/purchase_quotation.dart';
import '../../domain/repositories/purchase_quotation_repository.dart';

class MockPurchaseQuotationRepository
    implements PurchaseQuotationRepository {
  final List<PurchaseQuotation> _quotations = [
    PurchaseQuotation(
      id: 'purchase-quotation-001',
      projectId: 'project-001',
      supplierId: 'supplier-001',
      quotationNumber: 'PQ-2026-001',
      quotationDate: DateTime(2026, 8, 5),
      validUntil: DateTime(2026, 8, 20),
      subtotal: 485000,
      tax: 87300,
      discount: 10000,
      deliveryCharges: 5000,
      paymentTerms: '30 days credit',
      deliveryTerms: 'Delivery within 3 working days',
      notes: 'TMT steel requirement for structure phase.',
      status: PurchaseQuotationStatus.accepted,
    ),
    PurchaseQuotation(
      id: 'purchase-quotation-002',
      projectId: 'project-001',
      supplierId: 'supplier-002',
      quotationNumber: 'PQ-2026-002',
      quotationDate: DateTime(2026, 8, 8),
      validUntil: DateTime(2026, 8, 23),
      subtotal: 215000,
      tax: 38700,
      discount: 5000,
      deliveryCharges: 3000,
      paymentTerms: '15 days credit',
      deliveryTerms: 'Delivery within 2 working days',
      notes: 'Cement supply for foundation and structure.',
      status: PurchaseQuotationStatus.received,
    ),
    PurchaseQuotation(
      id: 'purchase-quotation-003',
      projectId: 'project-002',
      supplierId: 'supplier-003',
      quotationNumber: 'PQ-2026-003',
      quotationDate: DateTime(2026, 9, 1),
      validUntil: DateTime(2026, 9, 15),
      subtotal: 750000,
      tax: 135000,
      discount: 15000,
      deliveryCharges: 7500,
      paymentTerms: '30 days credit',
      deliveryTerms: 'Scheduled delivery',
      notes: 'Initial material quotation for commercial building.',
      status: PurchaseQuotationStatus.draft,
    ),
  ];

  @override
  Future<List<PurchaseQuotation>> getPurchaseQuotations(
    String projectId,
  ) async {
    return List.unmodifiable(
      _quotations.where(
        (quotation) =>
            quotation.projectId == projectId &&
            !quotation.isArchived,
      ),
    );
  }

  @override
  Future<PurchaseQuotation> getPurchaseQuotation(
    String id,
  ) async {
    return _quotations.firstWhere(
      (quotation) => quotation.id == id,
    );
  }

  @override
  Future<PurchaseQuotation> createPurchaseQuotation(
    PurchaseQuotation quotation,
  ) async {
    _quotations.add(quotation);
    return quotation;
  }

  @override
  Future<PurchaseQuotation> updatePurchaseQuotation(
    PurchaseQuotation quotation,
  ) async {
    final index = _quotations.indexWhere(
      (item) => item.id == quotation.id,
    );

    if (index == -1) {
      throw StateError(
        'Purchase quotation not found: ${quotation.id}',
      );
    }

    _quotations[index] = quotation;
    return quotation;
  }

  @override
  Future<void> archivePurchaseQuotation(
    String id,
  ) async {
    final index = _quotations.indexWhere(
      (quotation) => quotation.id == id,
    );

    if (index == -1) {
      throw StateError(
        'Purchase quotation not found: $id',
      );
    }

    final quotation = _quotations[index];

    _quotations[index] = PurchaseQuotation(
      id: quotation.id,
      projectId: quotation.projectId,
      supplierId: quotation.supplierId,
      quotationNumber: quotation.quotationNumber,
      quotationDate: quotation.quotationDate,
      validUntil: quotation.validUntil,
      subtotal: quotation.subtotal,
      tax: quotation.tax,
      discount: quotation.discount,
      deliveryCharges: quotation.deliveryCharges,
      paymentTerms: quotation.paymentTerms,
      deliveryTerms: quotation.deliveryTerms,
      notes: quotation.notes,
      status: quotation.status,
      isArchived: true,
    );
  }
}