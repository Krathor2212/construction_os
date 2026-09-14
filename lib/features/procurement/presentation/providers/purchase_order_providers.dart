import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_purchase_order_repository.dart';
import '../../domain/entities/purchase_order.dart';
import '../../domain/repositories/purchase_order_repository.dart';

final purchaseOrderRepositoryProvider =
    Provider<PurchaseOrderRepository>((ref) {
  return MockPurchaseOrderRepository();
});

final purchaseOrdersProvider =
    FutureProvider.family<
        List<PurchaseOrder>,
        String>(
  (ref, projectId) async {
    final repository = ref.watch(
      purchaseOrderRepositoryProvider,
    );

    return repository.getPurchaseOrders(
      projectId,
    );
  },
);

final purchaseOrderProvider =
    FutureProvider.family<
        PurchaseOrder,
        String>(
  (ref, orderId) async {
    final repository = ref.watch(
      purchaseOrderRepositoryProvider,
    );

    return repository.getPurchaseOrder(
      orderId,
    );
  },
);