import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/convert_purchase_quotation_to_order.dart';
import 'purchase_order_item_providers.dart';
import 'purchase_order_providers.dart';
import 'purchase_quotation_item_providers.dart';
import 'purchase_quotation_providers.dart';

final convertPurchaseQuotationToOrderProvider =
    Provider<ConvertPurchaseQuotationToOrder>((ref) {
  return ConvertPurchaseQuotationToOrder(
    purchaseQuotationRepository:
        ref.watch(purchaseQuotationRepositoryProvider),
    purchaseQuotationItemRepository:
        ref.watch(purchaseQuotationItemRepositoryProvider),
    purchaseOrderRepository:
        ref.watch(purchaseOrderRepositoryProvider),
    purchaseOrderItemRepository:
        ref.watch(purchaseOrderItemRepositoryProvider),
  );
});