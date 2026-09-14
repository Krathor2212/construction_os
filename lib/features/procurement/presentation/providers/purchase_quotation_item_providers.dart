import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_purchase_quotation_item_repository.dart';
import '../../domain/entities/purchase_quotation_item.dart';
import '../../domain/repositories/purchase_quotation_item_repository.dart';

final purchaseQuotationItemRepositoryProvider =
    Provider<PurchaseQuotationItemRepository>((ref) {
  return MockPurchaseQuotationItemRepository();
});

final purchaseQuotationItemsProvider =
    FutureProvider.family<
        List<PurchaseQuotationItem>,
        String>(
  (ref, quotationId) async {
    final repository = ref.watch(
      purchaseQuotationItemRepositoryProvider,
    );

    return repository.getItems(quotationId);
  },
);

final purchaseQuotationItemProvider =
    FutureProvider.family<
        PurchaseQuotationItem,
        String>(
  (ref, itemId) async {
    final repository = ref.watch(
      purchaseQuotationItemRepositoryProvider,
    );

    return repository.getItem(itemId);
  },
);