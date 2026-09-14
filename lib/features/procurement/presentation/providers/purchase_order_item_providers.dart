import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_purchase_order_item_repository.dart';
import '../../domain/entities/purchase_order_item.dart';
import '../../domain/repositories/purchase_order_item_repository.dart';

final purchaseOrderItemRepositoryProvider =
    Provider<PurchaseOrderItemRepository>((ref) {
  return MockPurchaseOrderItemRepository();
});

final purchaseOrderItemsProvider =
    FutureProvider.family<
        List<PurchaseOrderItem>,
        String>(
  (ref, purchaseOrderId) async {
    final repository = ref.watch(
      purchaseOrderItemRepositoryProvider,
    );

    return repository.getItems(
      purchaseOrderId,
    );
  },
);

final purchaseOrderItemProvider =
    FutureProvider.family<
        PurchaseOrderItem,
        String>(
  (ref, itemId) async {
    final repository = ref.watch(
      purchaseOrderItemRepositoryProvider,
    );

    return repository.getItem(itemId);
  },
);