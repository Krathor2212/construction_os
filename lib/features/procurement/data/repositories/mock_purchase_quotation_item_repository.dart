import '../../domain/entities/purchase_quotation_item.dart';
import '../../domain/repositories/purchase_quotation_item_repository.dart';

class MockPurchaseQuotationItemRepository
    implements PurchaseQuotationItemRepository {
  final List<PurchaseQuotationItem> _items = [
    PurchaseQuotationItem(
      id: 'purchase-item-001',
      quotationId: 'purchase-quotation-001',
      materialId: 'material-002',
      description: 'TMT Steel 12mm',
      quantity: 2500,
      unit: 'kg',
      unitRate: 62,
      taxRate: 18,
      notes: 'Fe 500 grade reinforcement steel.',
    ),
    PurchaseQuotationItem(
      id: 'purchase-item-002',
      quotationId: 'purchase-quotation-001',
      materialId: 'material-002',
      description: 'TMT Steel 16mm',
      quantity: 1500,
      unit: 'kg',
      unitRate: 64,
      taxRate: 18,
    ),
    PurchaseQuotationItem(
      id: 'purchase-item-003',
      quotationId: 'purchase-quotation-002',
      materialId: 'material-001',
      description: 'OPC Cement 53 Grade',
      quantity: 500,
      unit: 'bag',
      unitRate: 430,
      taxRate: 18,
      notes: 'Fresh stock required for site delivery.',
    ),
    PurchaseQuotationItem(
      id: 'purchase-item-004',
      quotationId: 'purchase-quotation-002',
      materialId: 'material-003',
      description: 'River Sand',
      quantity: 30,
      unit: 'm³',
      unitRate: 1850,
      taxRate: 5,
    ),
    PurchaseQuotationItem(
      id: 'purchase-item-005',
      quotationId: 'purchase-quotation-003',
      materialId: 'material-005',
      description: '20mm Aggregate',
      quantity: 100,
      unit: 'm³',
      unitRate: 1650,
      taxRate: 5,
    ),
  ];

  @override
  Future<List<PurchaseQuotationItem>> getItems(
    String quotationId,
  ) async {
    return List.unmodifiable(
      _items.where(
        (item) => item.quotationId == quotationId,
      ),
    );
  }

  @override
  Future<PurchaseQuotationItem> getItem(
    String id,
  ) async {
    return _items.firstWhere(
      (item) => item.id == id,
    );
  }

  @override
  Future<PurchaseQuotationItem> createItem(
    PurchaseQuotationItem item,
  ) async {
    _items.add(item);
    return item;
  }

  @override
  Future<PurchaseQuotationItem> updateItem(
    PurchaseQuotationItem item,
  ) async {
    final index = _items.indexWhere(
      (existing) => existing.id == item.id,
    );

    if (index == -1) {
      throw StateError(
        'Purchase quotation item not found: ${item.id}',
      );
    }

    _items[index] = item;
    return item;
  }

  @override
  Future<void> deleteItem(String id) async {
    final index = _items.indexWhere(
      (item) => item.id == id,
    );

    if (index == -1) {
      throw StateError(
        'Purchase quotation item not found: $id',
      );
    }

    _items.removeAt(index);
  }
}